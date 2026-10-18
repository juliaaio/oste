import os
import joblib
import pandas as pd

from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split, GridSearchCV, StratifiedKFold
from sklearn.preprocessing import OrdinalEncoder
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    roc_auc_score,
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATASET_PATH = os.path.join(BASE_DIR, "data", "osteoporosis.csv")
MODEL_DIR = os.path.join(BASE_DIR, "models")

os.makedirs(MODEL_DIR, exist_ok=True)


def load_data():
    df = pd.read_csv(DATASET_PATH)

    if "Id" in df.columns:
        df = df.drop(columns=["Id"])
    if "Hormonal Changes" in df.columns:
        df = df.drop(columns=["Hormonal Changes"])

    # Tangani missing values pada kolom kategorikal
    categorical_cols = df.select_dtypes(include=["object", "string"]).columns
    for col in categorical_cols:
        df[col] = df[col].fillna("None")

    return df


def preprocess_data(df):
    X = df.drop(columns=["Osteoporosis"]).copy()
    y = df["Osteoporosis"]

    # Ambil daftar kolom kategorikal
    categorical_cols = X.select_dtypes(include=["object", "string"]).columns.tolist()

    # Menggunakan OrdinalEncoder khusus fitur
    encoder = OrdinalEncoder(
        handle_unknown="use_encoded_value", 
        unknown_value=-1
    )
    
    X[categorical_cols] = encoder.fit_transform(X[categorical_cols])

    # Simpan encoder beserta daftar kolom kategorikal dalam satu struktur dict
    encoders_dict = {
        "ordinal_encoder": encoder,
        "categorical_cols": categorical_cols
    }

    return X, y, encoders_dict


def train_model(X_train, y_train):
    base_model = XGBClassifier(
        eval_metric="logloss",
        random_state=42
    )

    param_grid = {
        "n_estimators": [100, 200, 300],
        "max_depth": [3, 5],
        "learning_rate": [0.05, 0.1, 0.2],
        "subsample": [0.8, 1.0],
        "colsample_bytree": [0.8, 1.0]
    }

    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

    grid_search = GridSearchCV(
        estimator=base_model,
        param_grid=param_grid,
        scoring="f1",
        cv=cv,
        n_jobs=-1
    )

    print("=" * 26)
    print("RUNNING GRID SEARCH CV...")
    print("=" * 26)
    grid_search.fit(X_train, y_train)

    best_params = grid_search.best_params_
    print("\n" + "=" * 26)
    print("BEST PARAMETERS")
    print("=" * 26)
    print(f"n_estimators      = {best_params.get('n_estimators')}")
    print(f"max_depth         = {best_params.get('max_depth')}")
    print(f"learning_rate     = {best_params.get('learning_rate')}")
    print(f"subsample         = {best_params.get('subsample')}")
    print(f"colsample_bytree  = {best_params.get('colsample_bytree')}")
    print(f"Best CV Score (F1)= {grid_search.best_score_:.4f}")

    return grid_search.best_estimator_


def evaluate_model(model, X_test, y_test, X_train=None, y_train=None):
    prediction = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    # Evaluation Metrics
    print("\n" + "=" * 26)
    print("EVALUATION METRICS")
    print("=" * 26)
    print(f"Accuracy         : {accuracy_score(y_test, prediction):.4f}")
    print(f"Precision        : {precision_score(y_test, prediction):.4f}")
    print(f"Recall           : {recall_score(y_test, prediction):.4f}")
    print(f"F1 Score         : {f1_score(y_test, prediction):.4f}")
    print(f"ROC-AUC          : {roc_auc_score(y_test, y_prob):.4f}")

    if X_train is not None and y_train is not None:
        train_pred = model.predict(X_train)
        print("-" * 26)
        print(f"Train Accuracy   : {accuracy_score(y_train, train_pred):.4f}")
        print(f"Test Accuracy    : {accuracy_score(y_test, prediction):.4f}")
        print(f"Train F1 Score   : {f1_score(y_train, train_pred):.4f}")

    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, prediction))

    # Feature importances
    feature_names = getattr(model, "feature_names_in_", X_test.columns.to_numpy())
    importances = model.feature_importances_

    feature_importance_df = pd.DataFrame({
        "Feature": feature_names,
        "Importance": importances
    }).sort_values(by="Importance", ascending=False).reset_index(drop=True)

    print("\n" + "=" * 26)
    print("FEATURE IMPORTANCE")
    print("=" * 26)
    for _, row in feature_importance_df.iterrows():
        print(f"{row['Feature']:<24} {row['Importance']:.4f}")


def save_model(model, encoders_dict):
    joblib.dump(
        model,
        os.path.join(MODEL_DIR, "xgb_model.pkl")
    )

    joblib.dump(
        encoders_dict,
        os.path.join(MODEL_DIR, "xgb_encoders.pkl")
    )


def main():
    df = load_data()

    X, y, encoders_dict = preprocess_data(df)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )

    model = train_model(X_train, y_train)

    evaluate_model(model, X_test, y_test, X_train=X_train, y_train=y_train)

    save_model(model, encoders_dict)

    print("\nModel dan Encoder berhasil disimpan.")


if __name__ == "__main__":
    main()