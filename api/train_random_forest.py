import os
import joblib
import pandas as pd

from sklearn.model_selection import train_test_split, GridSearchCV, StratifiedKFold
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
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

    # Tangani missing values pada kolom kategorikal secara eksplisit
    categorical_cols = df.select_dtypes(include=["object"]).columns
    for col in categorical_cols:
        df[col] = df[col].fillna("None")

    return df


def preprocess_data(df):
    encoders = {}

    for column in df.columns:
        # Jangan encode kolom target
        if column == "Osteoporosis":
            continue

        # Encode semua kolom yang bukan numerik
        if not pd.api.types.is_numeric_dtype(df[column]):
            encoder = LabelEncoder()

            df[column] = encoder.fit_transform(
                df[column].astype(str)
            )

            encoders[column] = encoder

    X = df.drop(columns=["Osteoporosis"])
    y = df["Osteoporosis"]

    return X, y, encoders


def train_model(X_train, y_train):
    base_model = RandomForestClassifier(
        random_state=42
    )

    param_grid = {
        "n_estimators": [100, 200, 300],
        "max_depth": [5, 10, 15, None],
        "min_samples_split": [2, 5, 10],
        "min_samples_leaf": [1, 2, 5],
        "max_features": ["sqrt", "log2"]
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
    print(f"n_estimators = {best_params.get('n_estimators')}")
    print(f"max_depth = {best_params.get('max_depth')}")
    print(f"min_samples_leaf = {best_params.get('min_samples_leaf')}")
    print(f"min_samples_split = {best_params.get('min_samples_split')}")
    print(f"max_features = {best_params.get('max_features')}")
    print(f"Best CV Score (F1) = {grid_search.best_score_:.4f}")

    return grid_search.best_estimator_


def evaluate_model(model, X_test, y_test, X_train=None, y_train=None):
    prediction = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    # 1. Evaluation Metrics
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

    # Feature importances and usage analysis
    feature_names = getattr(model, "feature_names_in_", None)
    if feature_names is None:
        feature_names = X_test.columns.to_numpy()

    importances = model.feature_importances_
    total_features = len(feature_names)

    feature_importance_df = pd.DataFrame({
        "Feature": feature_names,
        "Importance": importances
    }).sort_values(by="Importance", ascending=False).reset_index(drop=True)

    used_features_df = feature_importance_df[feature_importance_df["Importance"] > 0]
    unused_features_df = feature_importance_df[feature_importance_df["Importance"] == 0]
    num_features_used = len(used_features_df)

    # 2. Forest Information
    avg_depth = sum(tree.get_depth() for tree in model.estimators_) / len(model.estimators_)
    print("\n" + "=" * 26)
    print("FOREST INFORMATION")
    print("=" * 26)
    print(f"Number of Trees         : {len(model.estimators_)}")
    print(f"Max Depth (average)     : {avg_depth:.2f}")
    print(f"Number of Features Used : {num_features_used} / {total_features}")

    # 3. Feature Importance
    print("\n" + "=" * 26)
    print("FEATURE IMPORTANCE")
    print("=" * 26)
    for _, row in feature_importance_df.iterrows():
        print(f"{row['Feature']:<24} {row['Importance']:.4f}")

    # 4. Unused Features
    print("\n" + "=" * 26)
    print("UNUSED FEATURES")
    print("=" * 26)
    if len(unused_features_df) > 0:
        for feat in unused_features_df["Feature"]:
            print(feat)
    else:
        print("(None)")

    # 5. Features Used Summary Count
    print("\nFeatures used:")
    print(f"{num_features_used} / {total_features}")


def save_model(model, encoders):
    joblib.dump(
        model,
        os.path.join(MODEL_DIR, "rf_model.pkl")
    )

    joblib.dump(
        encoders,
        os.path.join(MODEL_DIR, "rf_encoders.pkl")
    )


def main():
    df = load_data()

    X, y, encoders = preprocess_data(df)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )

    model = train_model(X_train, y_train)

    evaluate_model(model, X_test, y_test, X_train=X_train, y_train=y_train)

    save_model(model, encoders)

    print("\nModel berhasil disimpan.")


if __name__ == "__main__":
    main()
