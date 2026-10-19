import os
import joblib
import pandas as pd
from typing import Optional, Union
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# ==========================
# Load model & encoders
# ==========================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "models", "rf_model.pkl")
ENCODERS_PATH = os.path.join(BASE_DIR, "models", "rf_encoders.pkl")

model = joblib.load(MODEL_PATH)
encoders = joblib.load(ENCODERS_PATH)

app = FastAPI(
    title="Osteoporosis Prediction API"
)

# Enable CORS for Flutter Web / Chrome
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================
# Input Model
# Mendukung format nama kolom dengan spasi / slash (dari Flutter)
# maupun format underscore (Pydantic standard)
# ==========================

class PredictionRequest(BaseModel):
    Age: int = 50
    Gender: str = "Female"
    Family_History: Optional[str] = Field(default="No", alias="Family History")
    Race_Ethnicity: Optional[str] = Field(default="Asian", alias="Race/Ethnicity")
    Body_Weight: Optional[str] = Field(default="Normal", alias="Body Weight")
    Calcium_Intake: Optional[str] = Field(default="Adequate", alias="Calcium Intake")
    Vitamin_D_Intake: Optional[str] = Field(default="Sufficient", alias="Vitamin D Intake")
    Physical_Activity: Optional[str] = Field(default="Active", alias="Physical Activity")
    Smoking: Optional[Union[str, int]] = "No"
    Alcohol_Consumption: Optional[Union[str, int]] = Field(default="None", alias="Alcohol Consumption")
    Medical_Conditions: Optional[str] = Field(default="None", alias="Medical Conditions")
    Medications: Optional[str] = Field(default="None", alias="Medications")
    Prior_Fractures: Optional[Union[str, int]] = Field(default="No", alias="Prior Fractures")
    Hormonal_Changes: Optional[str] = Field(default=None, alias="Hormonal Changes")

    class Config:
        populate_by_name = True
        extra = "allow"


# ==========================
# Home
# ==========================

@app.get("/")
def home():
    return {
        "message": "Osteoporosis API Running",
        "status": "healthy"
    }


# ==========================
# Helper Normalizer
# ==========================

def _clean_str(val, default="None"):
    if val is None:
        return default
    s = str(val).strip()
    if s.lower() in ["unknown", "nan", "none", "", "null", "string"]:
        return default
    return s


def _normalize_body_weight(val: str) -> str:
    s = str(val).strip().lower()
    if "under" in s or "kurus" in s:
        return "Underweight"
    # Backend encoder hanya mengenali ['Normal', 'Underweight']
    # Maka Overweight, Obese, Berlebih dipetakan ke Normal
    return "Normal"


def _normalize_vitamin_d(val: str) -> str:
    s = str(val).strip().lower()
    if "insufficient" in s or "rendah" in s or "low" in s or "kurang" in s:
        return "Insufficient"
    return "Sufficient"


def _normalize_calcium(val: str) -> str:
    s = str(val).strip().lower()
    if "low" in s or "rendah" in s or "kurang" in s:
        return "Low"
    return "Adequate"


def _normalize_yes_no(val: Union[str, int], yes_val="Yes", no_val="No") -> str:
    if isinstance(val, (int, float)):
        return yes_val if val == 1 else no_val
    s = str(val).strip().lower()
    if s in ["1", "yes", "ya", "iya", "true"]:
        return yes_val
    return no_val


def _normalize_alcohol(val: Union[str, int]) -> str:
    if isinstance(val, (int, float)):
        return "Moderate" if val == 1 else "None"
    s = str(val).strip().lower()
    if s in ["1", "yes", "ya", "iya", "true", "moderate"]:
        return "Moderate"
    return "None"


# ==========================
# Prediction
# ==========================

@app.post("/predict")
def predict(data: PredictionRequest):
    # Mapping request ke fitur kolom training model
    raw_data = {
        "Age": int(data.Age),
        "Gender": "Male" if "male" in str(data.Gender).lower() or "laki" in str(data.Gender).lower() else "Female",
        "Family History": _normalize_yes_no(data.Family_History),
        "Race/Ethnicity": _clean_str(data.Race_Ethnicity, default="Asian"),
        "Body Weight": _normalize_body_weight(data.Body_Weight),
        "Calcium Intake": _normalize_calcium(data.Calcium_Intake),
        "Vitamin D Intake": _normalize_vitamin_d(data.Vitamin_D_Intake),
        "Physical Activity": "Sedentary" if "sedentary" in str(data.Physical_Activity).lower() or "kurang" in str(data.Physical_Activity).lower() else "Active",
        "Smoking": _normalize_yes_no(data.Smoking),
        "Alcohol Consumption": _normalize_alcohol(data.Alcohol_Consumption),
        "Medical Conditions": _clean_str(data.Medical_Conditions, default="None"),
        "Medications": _clean_str(data.Medications, default="None"),
        "Prior Fractures": _normalize_yes_no(data.Prior_Fractures),
    }

    # Penyelarasan format ras jika perlu
    race = raw_data["Race/Ethnicity"].lower()
    if "african" in race or "afrika" in race:
        raw_data["Race/Ethnicity"] = "African American"
    elif "caucasian" in race or "kaukasia" in race:
        raw_data["Race/Ethnicity"] = "Caucasian"
    else:
        raw_data["Race/Ethnicity"] = "Asian"

    # Penyelarasan kondisi medis
    med_cond = raw_data["Medical Conditions"].lower()
    if "hyperthyroid" in med_cond or "hipertiroid" in med_cond:
        raw_data["Medical Conditions"] = "Hyperthyroidism"
    elif "arthrit" in med_cond or "artritis" in med_cond:
        raw_data["Medical Conditions"] = "Rheumatoid Arthritis"
    else:
        raw_data["Medical Conditions"] = "None"

    # Penyelarasan obat
    meds = raw_data["Medications"].lower()
    if "corticosteroid" in meds or "kortikosteroid" in meds:
        raw_data["Medications"] = "Corticosteroids"
    else:
        raw_data["Medications"] = "None"

    df = pd.DataFrame([raw_data])

    # Encode categorical columns
    if isinstance(encoders, dict):
        for col, encoder in encoders.items():
            if col in df.columns:
                val = str(df[col].iloc[0])
                if hasattr(encoder, "classes_"):
                    if val not in encoder.classes_:
                        # Fallback aman ke class pertama jika nilai di luar kelas yang diketahui
                        val = "None" if "None" in encoder.classes_ else encoder.classes_[0]
                    df[col] = encoder.transform([val])
                elif hasattr(encoder, "transform"):
                    df[col] = encoder.transform(df[col])

    # Align column order with the model's expected feature names
    if hasattr(model, "feature_names_in_"):
        df = df[model.feature_names_in_]

    # Predict class and probability
    prediction = int(model.predict(df)[0])
    probabilities = model.predict_proba(df)[0]

    confidence = round(float(max(probabilities) * 100), 2)

    # Class 1 corresponds to Osteoporosis positive
    class_1_idx = list(model.classes_).index(1) if 1 in model.classes_ else 1
    osteoporosis_probability = round(float(probabilities[class_1_idx] * 100), 2)

    return {
        "prediction": prediction,
        "probability": osteoporosis_probability,
        "confidence": confidence
    }
