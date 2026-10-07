import os
import joblib
import pandas as pd
from fastapi import FastAPI
from pydantic import BaseModel

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

# ==========================
# Input Model
# ==========================

class PredictionRequest(BaseModel):
    Age: int
    Gender: str
    Hormonal_Changes: str
    Family_History: str
    Race_Ethnicity: str
    Body_Weight: str
    Calcium_Intake: str
    Vitamin_D_Intake: str
    Physical_Activity: str
    Smoking: str
    Alcohol_Consumption: str
    Medical_Conditions: str
    Medications: str
    Prior_Fractures: str


# ==========================
# Home
# ==========================

@app.get("/")
def home():
    return {
        "message": "Osteoporosis API Running"
    }


# ==========================
# Prediction
# ==========================

@app.post("/predict")
def predict(data: PredictionRequest):
    # Build DataFrame matching training dataset column names
    raw_data = {
        "Age": data.Age,
        "Gender": data.Gender,
        "Hormonal Changes": data.Hormonal_Changes,
        "Family History": data.Family_History,
        "Race/Ethnicity": data.Race_Ethnicity,
        "Body Weight": data.Body_Weight,
        "Calcium Intake": data.Calcium_Intake,
        "Vitamin D Intake": data.Vitamin_D_Intake,
        "Physical Activity": data.Physical_Activity,
        "Smoking": data.Smoking,
        "Alcohol Consumption": data.Alcohol_Consumption,
        "Medical Conditions": data.Medical_Conditions,
        "Medications": data.Medications,
        "Prior Fractures": data.Prior_Fractures
    }

    # Normalize values: Ubah 'Unknown', 'nan', 'string', atau string kosong menjadi 'None'
    for k, v in raw_data.items():
        if isinstance(v, str) and v.strip().lower() in ["unknown", "nan", "none", "", "null", "string"]:
            raw_data[k] = "None"

    df = pd.DataFrame([raw_data])

    # Encode categorical columns after validating/mapping allowed values
    for col, encoder in encoders.items():
        if col in df.columns:
            val = df[col].iloc[0]
            
            # Jika nilai masih tidak ada di encoder classes, gunakan fallback 'None' atau kelas pertama
            if val not in encoder.classes_:
                if "None" in encoder.classes_:
                    df[col] = "None"
                else:
                    return {
                        "error": f"Invalid value '{val}' for column '{col}'.",
                        "allowed_values": encoder.classes_.tolist()
                    }

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