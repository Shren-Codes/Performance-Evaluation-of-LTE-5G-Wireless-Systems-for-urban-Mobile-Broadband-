"""
============================================================
 Performance Evaluation of LTE/5G Wireless Systems
 Python – Machine Learning Module (Member 5)
 Course  : BECE317L – Wireless Mobile Communication
 Student : SHRENICA CHAWDA A | 23BEC1380
 Guide   : Dr. VETRIVELAN. P
 School  : SENSE, VIT Chennai | April 2026

 WHAT THIS FILE DOES
 ────────────────────────────────────────────────────────────
  1.  Dataset Generation  – synthetic LTE-like channel data
      with physically motivated SNR–distance relationship
      (log-distance path loss + log-normal shadowing)
  2.  Exploratory Analysis – 6 diagnostic plots
  3.  Model Training – Random Forest, Logistic Regression, SVM
  4.  Evaluation     – accuracy, confusion matrix, feature
                       importance, model comparison bar chart
  5.  Live Demo      – predict modulation for a given input

 REQUIREMENTS
 ────────────────────────────────────────────────────────────
  pip install numpy pandas matplotlib scikit-learn
============================================================
"""

# ── 0.  Imports ──────────────────────────────────────────────
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import ListedColormap

from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import (
    accuracy_score, confusion_matrix, ConfusionMatrixDisplay,
    classification_report
)
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler

import warnings
warnings.filterwarnings("ignore")

# ── Reproducibility ──────────────────────────────────────────
SEED = 42
np.random.seed(SEED)

print("=" * 56)
print("  LTE/5G Adaptive Modulation  –  ML Module")
print("=" * 56, "\n")

# ============================================================
#  STEP 1 : DATASET GENERATION
# ============================================================
print("─" * 40)
print(" STEP 1 : Generating Synthetic Dataset")
print("─" * 40)

# ── 1.1  Configuration ───────────────────────────────────────
N               = 2000          # total samples
PATH_LOSS_EXP   = 3.2           # urban macro-cell exponent
P_TX_REF_dB     = 30            # reference TX power (dB)
SHADOW_STD_dB   = 3.0           # log-normal shadowing σ (dB)
NOISE_FLOOR_MIN = -100          # minimum noise floor (dBm)
NOISE_FLOOR_MAX = -85           # maximum noise floor (dBm)
LABEL_NOISE_PROB= 0.05          # fraction of randomly flipped labels
D_MIN_km        = 0.1           # minimum distance (km)
D_MAX_km        = 5.0           # maximum distance (km)

# SNR thresholds → modulation labels
SNR_THRESH_QPSK   = 10.0        # < 10 dB  → QPSK    (label 0)
SNR_THRESH_16QAM  = 20.0        # 10–20 dB → 16-QAM  (label 1)
                                 # ≥ 20 dB  → 64-QAM  (label 2)

# ── 1.2  Feature Generation ─────────────────────────────────
distance = np.random.uniform(D_MIN_km, D_MAX_km, N)

# Physically motivated SNR: path loss + shadowing
SNR = (P_TX_REF_dB
       - 10 * PATH_LOSS_EXP * np.log10(distance)
       + np.random.normal(0, SHADOW_STD_dB, N))

noise = np.random.uniform(NOISE_FLOOR_MIN, NOISE_FLOOR_MAX, N)

# ── 1.3  Label Assignment ────────────────────────────────────
def assign_label(snr_val):
    """Map SNR to modulation label with threshold rule."""
    if   snr_val < SNR_THRESH_QPSK:  return 0   # QPSK
    elif snr_val < SNR_THRESH_16QAM: return 1   # 16-QAM
    else:                             return 2   # 64-QAM

labels_clean = np.array([assign_label(s) for s in SNR])

# Inject 5% random label noise to simulate estimation errors
flip_mask = np.random.rand(N) < LABEL_NOISE_PROB
labels = labels_clean.copy()
labels[flip_mask] = np.random.choice([0, 1, 2], size=flip_mask.sum())

# ── 1.4  DataFrame ───────────────────────────────────────────
df = pd.DataFrame({
    "SNR_dB":    SNR,
    "Distance":  distance,
    "Noise_dBm": noise,
    "Label":     labels
})

MOD_MAP   = {0: "QPSK", 1: "16-QAM", 2: "64-QAM"}
LABEL_STR = [MOD_MAP[l] for l in labels]

print(f"Dataset shape       : {df.shape}")
print(f"Label distribution  : {dict(pd.Series(labels).value_counts().sort_index())}")
print(f"  0 → QPSK    : {(labels==0).sum()} samples")
print(f"  1 → 16-QAM  : {(labels==1).sum()} samples")
print(f"  2 → 64-QAM  : {(labels==2).sum()} samples")
print(f"SNR  range          : [{SNR.min():.1f}, {SNR.max():.1f}] dB")
print(f"Distance range      : [{distance.min():.2f}, {distance.max():.2f}] km")
print()
print(df.head())

# Optional: save to CSV
df.to_csv("wireless_dataset.csv", index=False)
print("\nDataset saved → wireless_dataset.csv\n")

# ============================================================
#  STEP 2 : EXPLORATORY VISUALISATION  (6 plots)
# ============================================================
print("─" * 40)
print(" STEP 2 : Exploratory Analysis Plots")
print("─" * 40)

COLORS = ["#1f77b4", "#ff7f0e", "#2ca02c"]   # blue / orange / green
MOD_LABELS = ["QPSK (0)", "16-QAM (1)", "64-QAM (2)"]

# ── Plot A : Distance vs SNR ─────────────────────────────────
fig, ax = plt.subplots(figsize=(8, 5))
ax.scatter(df["Distance"], df["SNR_dB"], alpha=0.4, s=12,
           color="#1f77b4", edgecolors="none")
ax.set_xlabel("Distance (km)", fontsize=12)
ax.set_ylabel("SNR (dB)",      fontsize=12)
ax.set_title("Distance vs SNR  (Path Loss Effect)", fontsize=14, fontweight="bold")
ax.grid(True, linestyle="--", alpha=0.5)
# Overlay theoretical path loss curve
d_theory = np.linspace(0.05, 5.0, 400)
snr_theory = P_TX_REF_dB - 10 * PATH_LOSS_EXP * np.log10(d_theory)
ax.plot(d_theory, snr_theory, "r-", lw=2, label="Theoretical (no shadowing)")
ax.legend(fontsize=10)
plt.tight_layout()
plt.savefig("plot_A_distance_vs_snr.png", dpi=150)
plt.show()
print("  Saved: plot_A_distance_vs_snr.png")

# ── Plot B : SNR Distribution ────────────────────────────────
fig, ax = plt.subplots(figsize=(8, 5))
ax.hist(df["SNR_dB"], bins=35, color="#1f77b4", edgecolor="white", linewidth=0.5)
ax.axvline(SNR_THRESH_QPSK,  color="orange", lw=2, ls="--", label="QPSK/16-QAM  10 dB")
ax.axvline(SNR_THRESH_16QAM, color="green",  lw=2, ls="--", label="16-QAM/64-QAM 20 dB")
ax.set_xlabel("SNR (dB)",  fontsize=12)
ax.set_ylabel("Frequency", fontsize=12)
ax.set_title("SNR Distribution  (Physically Motivated)", fontsize=14, fontweight="bold")
ax.legend(fontsize=10)
ax.grid(True, linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("plot_B_snr_distribution.png", dpi=150)
plt.show()
print("  Saved: plot_B_snr_distribution.png")

# ── Plot C : SNR vs Modulation ───────────────────────────────
fig, ax = plt.subplots(figsize=(8, 5))
for lbl in [0, 1, 2]:
    mask = labels == lbl
    ax.scatter(df["SNR_dB"][mask], np.full(mask.sum(), lbl),
               alpha=0.5, s=18, color=COLORS[lbl], label=MOD_LABELS[lbl],
               edgecolors="none")
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(["QPSK (0)", "16-QAM (1)", "64-QAM (2)"], fontsize=11)
ax.axvline(SNR_THRESH_QPSK,  color="k", lw=1.5, ls="--", alpha=0.6)
ax.axvline(SNR_THRESH_16QAM, color="k", lw=1.5, ls="--", alpha=0.6)
ax.set_xlabel("SNR (dB)",        fontsize=12)
ax.set_ylabel("Modulation Class",fontsize=12)
ax.set_title("SNR vs Modulation Classification Scatter", fontsize=14, fontweight="bold")
ax.legend(fontsize=10, loc="center right")
ax.grid(True, linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("plot_C_snr_vs_modulation.png", dpi=150)
plt.show()
print("  Saved: plot_C_snr_vs_modulation.png")

# ── Plot D : Distance vs Modulation ─────────────────────────
fig, ax = plt.subplots(figsize=(8, 5))
for lbl in [0, 1, 2]:
    mask = labels == lbl
    ax.scatter(df["Distance"][mask], np.full(mask.sum(), lbl),
               alpha=0.5, s=18, color=COLORS[lbl], label=MOD_LABELS[lbl],
               edgecolors="none")
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(["QPSK (0)", "16-QAM (1)", "64-QAM (2)"], fontsize=11)
ax.set_xlabel("Distance (km)",   fontsize=12)
ax.set_ylabel("Modulation Class",fontsize=12)
ax.set_title("Distance vs Modulation", fontsize=14, fontweight="bold")
ax.legend(fontsize=10)
ax.grid(True, linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("plot_D_distance_vs_modulation.png", dpi=150)
plt.show()
print("  Saved: plot_D_distance_vs_modulation.png")

# ── Plot E : Noise vs Modulation ─────────────────────────────
fig, ax = plt.subplots(figsize=(8, 5))
for lbl in [0, 1, 2]:
    mask = labels == lbl
    ax.scatter(df["Noise_dBm"][mask], np.full(mask.sum(), lbl),
               alpha=0.5, s=18, color=COLORS[lbl], label=MOD_LABELS[lbl],
               edgecolors="none")
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(["QPSK (0)", "16-QAM (1)", "64-QAM (2)"], fontsize=11)
ax.set_xlabel("Noise Floor (dBm)",fontsize=12)
ax.set_ylabel("Modulation Class", fontsize=12)
ax.set_title("Noise Floor vs Modulation", fontsize=14, fontweight="bold")
ax.legend(fontsize=10)
ax.grid(True, linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("plot_E_noise_vs_modulation.png", dpi=150)
plt.show()
print("  Saved: plot_E_noise_vs_modulation.png")

print()

# ============================================================
#  STEP 3 : TRAIN / TEST SPLIT
# ============================================================
print("─" * 40)
print(" STEP 3 : Train / Test Split  (80 / 20)")
print("─" * 40)

FEATURE_COLS = ["SNR_dB", "Distance", "Noise_dBm"]
X = df[FEATURE_COLS].values
y = df["Label"].values

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=SEED, stratify=y
)

print(f"Training samples : {len(X_train)}")
print(f"Test samples     : {len(X_test)}")
print(f"Features         : {FEATURE_COLS}\n")

# Feature scaling for LR and SVM
scaler    = StandardScaler()
X_tr_sc   = scaler.fit_transform(X_train)
X_te_sc   = scaler.transform(X_test)

# ============================================================
#  STEP 4 : TRAIN ALL THREE CLASSIFIERS
# ============================================================
print("─" * 40)
print(" STEP 4 : Training Classifiers")
print("─" * 40)

# ── Random Forest ────────────────────────────────────────────
rf_model = RandomForestClassifier(
    n_estimators = 100,
    max_depth    = 6,
    random_state = SEED,
    n_jobs       = -1
)
rf_model.fit(X_train, y_train)
rf_pred = rf_model.predict(X_test)
rf_acc  = accuracy_score(y_test, rf_pred)

rf_cv   = cross_val_score(rf_model, X, y, cv=5, scoring="accuracy")
print(f"Random Forest      – Test Acc: {rf_acc*100:.2f}%  "
      f"| 5-fold CV: {rf_cv.mean()*100:.2f}% ± {rf_cv.std()*100:.2f}%")

# ── Logistic Regression ──────────────────────────────────────
lr_model = LogisticRegression(
    max_iter     = 300,
    C            = 1.0,
    solver       = "lbfgs",
    random_state = SEED,
    multi_class  = "multinomial"
)
lr_model.fit(X_tr_sc, y_train)
lr_pred  = lr_model.predict(X_te_sc)
lr_acc   = accuracy_score(y_test, lr_pred)
lr_cv    = cross_val_score(lr_model,
                            scaler.fit_transform(X), y, cv=5,
                            scoring="accuracy")
print(f"Logistic Regression– Test Acc: {lr_acc*100:.2f}%  "
      f"| 5-fold CV: {lr_cv.mean()*100:.2f}% ± {lr_cv.std()*100:.2f}%")

# ── SVM (RBF kernel) ─────────────────────────────────────────
svm_model = SVC(
    kernel       = "rbf",
    C            = 1.0,
    gamma        = "scale",
    random_state = SEED,
    probability  = True
)
svm_model.fit(X_tr_sc, y_train)
svm_pred  = svm_model.predict(X_te_sc)
svm_acc   = accuracy_score(y_test, svm_pred)
svm_cv    = cross_val_score(svm_model,
                             scaler.fit_transform(X), y, cv=5,
                             scoring="accuracy")
print(f"SVM (RBF)          – Test Acc: {svm_acc*100:.2f}%  "
      f"| 5-fold CV: {svm_cv.mean()*100:.2f}% ± {svm_cv.std()*100:.2f}%")

print()

# ============================================================
#  STEP 5 : SELECT BEST MODEL
# ============================================================
print("─" * 40)
print(" STEP 5 : Best Model Selection")
print("─" * 40)

results = {
    "Random Forest":       (rf_acc,  rf_pred,  rf_model),
    "Logistic Regression": (lr_acc,  lr_pred,  lr_model),
    "SVM (RBF)":           (svm_acc, svm_pred, svm_model),
}

best_name  = max(results, key=lambda k: results[k][0])
best_acc, best_pred, best_model = results[best_name]

print(f"Best Model : {best_name}  →  {best_acc*100:.2f}% accuracy\n")
print("Classification Report (best model):")
print(classification_report(y_test, best_pred,
                             target_names=["QPSK","16-QAM","64-QAM"]))

# ============================================================
#  STEP 6 : VISUALISATION  –  ML Results
# ============================================================
print("─" * 40)
print(" STEP 6 : Result Plots")
print("─" * 40)

# ── Plot F : Confusion Matrix ────────────────────────────────
fig, ax = plt.subplots(figsize=(7, 6))
cm  = confusion_matrix(y_test, best_pred)
disp = ConfusionMatrixDisplay(confusion_matrix=cm,
                               display_labels=["QPSK","16-QAM","64-QAM"])
disp.plot(ax=ax, colorbar=True, cmap="viridis")
ax.set_title(f"Confusion Matrix  –  {best_name}\n(Test Accuracy: {best_acc*100:.1f}%)",
             fontsize=13, fontweight="bold")
plt.tight_layout()
plt.savefig("plot_F_confusion_matrix.png", dpi=150)
plt.show()
print("  Saved: plot_F_confusion_matrix.png")

# ── Plot G : Model Accuracy Comparison ──────────────────────
fig, ax = plt.subplots(figsize=(8, 5))
model_names  = list(results.keys())
model_accs   = [results[k][0]*100 for k in model_names]
bar_colors   = ["#1f77b4" if k != best_name else "#d62728" for k in model_names]
bars = ax.bar(model_names, model_accs, color=bar_colors, edgecolor="white", width=0.5)
ax.set_ylim([0, 105])
ax.set_ylabel("Test Accuracy (%)", fontsize=12)
ax.set_title("Model Accuracy Comparison", fontsize=14, fontweight="bold")
ax.grid(True, axis="y", linestyle="--", alpha=0.6)
for bar, acc in zip(bars, model_accs):
    ax.text(bar.get_x() + bar.get_width()/2, acc + 0.5,
            f"{acc:.2f}%", ha="center", va="bottom", fontsize=11,
            fontweight="bold")
ax.text(0.98, 0.02, "■ Best Model", transform=ax.transAxes,
        ha="right", va="bottom", color="#d62728", fontsize=10)
plt.tight_layout()
plt.savefig("plot_G_model_comparison.png", dpi=150)
plt.show()
print("  Saved: plot_G_model_comparison.png")

# ── Plot H : Feature Importance (Random Forest) ──────────────
fig, ax = plt.subplots(figsize=(7, 4))
importance = rf_model.feature_importances_
feat_labels = ["SNR (dB)", "Distance (km)", "Noise Floor (dBm)"]
sort_idx    = np.argsort(importance)[::-1]
ax.bar(np.array(feat_labels)[sort_idx],
       importance[sort_idx],
       color=["#1f77b4","#ff7f0e","#2ca02c"],
       edgecolor="white")
ax.set_ylabel("Feature Importance\n(Mean Gini Decrease)", fontsize=12)
ax.set_title("Random Forest  –  Feature Importance", fontsize=14, fontweight="bold")
ax.set_ylim([0, 1.05])
for i, (idx, imp) in enumerate(zip(sort_idx, importance[sort_idx])):
    ax.text(i, imp + 0.01, f"{imp:.3f}", ha="center", fontsize=11)
ax.grid(True, axis="y", linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("plot_H_feature_importance.png", dpi=150)
plt.show()
print("  Saved: plot_H_feature_importance.png")

# ── Plot I : Decision Boundary (SNR vs Distance, 2D projection)
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
model_items = [
    ("Random Forest",       rf_model,  X_train, y_train),
    ("Logistic Regression", lr_model,  X_tr_sc, y_train),
    ("SVM (RBF)",           svm_model, X_tr_sc, y_train),
]
cmap_light = ListedColormap(["#AEC6FF","#FFD7A8","#B8F0B8"])
cmap_bold  = ListedColormap(["#1f77b4","#ff7f0e","#2ca02c"])

for ax, (name, model, Xtr, ytr) in zip(axes, model_items):
    # Use only SNR and Distance (columns 0 and 1)
    x_min, x_max = X[:,0].min()-2, X[:,0].max()+2
    y_min, y_max = X[:,1].min()-0.2, X[:,1].max()+0.2
    xx, yy = np.meshgrid(np.linspace(x_min, x_max, 180),
                          np.linspace(y_min, y_max, 180))
    # Fix Noise at its median
    noise_med = np.median(df["Noise_dBm"].values)
    grid_flat = np.c_[xx.ravel(), yy.ravel(),
                       np.full(xx.ravel().shape, noise_med)]
    if name != "Random Forest":
        grid_flat = scaler.transform(grid_flat)
    Z = model.predict(grid_flat).reshape(xx.shape)
    ax.contourf(xx, yy, Z, alpha=0.35, cmap=cmap_light)
    for lbl, col in zip([0,1,2], ["#1f77b4","#ff7f0e","#2ca02c"]):
        m = y_test == lbl
        ax.scatter(X_test[m,0], X_test[m,1],
                   c=col, s=12, alpha=0.7, edgecolors="none",
                   label=MOD_LABELS[lbl])
    ax.set_xlabel("SNR (dB)",      fontsize=10)
    ax.set_ylabel("Distance (km)", fontsize=10)
    ax.set_title(f"{name}\nAcc = {results[name][0]*100:.1f}%", fontsize=11)
    ax.legend(fontsize=8, loc="upper right")
    ax.grid(True, linestyle="--", alpha=0.4)

plt.suptitle("Decision Boundaries  –  SNR vs Distance  (Noise fixed at median)",
             fontsize=13, fontweight="bold")
plt.tight_layout()
plt.savefig("plot_I_decision_boundaries.png", dpi=150)
plt.show()
print("  Saved: plot_I_decision_boundaries.png")
print()

# ============================================================
#  STEP 7 : COMPREHENSIVE SUMMARY DASHBOARD  (single figure)
# ============================================================
print("─" * 40)
print(" STEP 7 : Summary Dashboard")
print("─" * 40)

fig = plt.figure(figsize=(18, 12))
gs  = gridspec.GridSpec(2, 3, figure=fig, hspace=0.40, wspace=0.35)

# ── Panel 1 : Distance vs SNR ────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])
ax1.scatter(df["Distance"], df["SNR_dB"], alpha=0.3, s=8,
            color="#1f77b4", edgecolors="none")
ax1.plot(d_theory, snr_theory, "r-", lw=2, label="Theoretical")
ax1.axhline(SNR_THRESH_QPSK,  color="orange", lw=1.5, ls="--", alpha=0.8)
ax1.axhline(SNR_THRESH_16QAM, color="green",  lw=1.5, ls="--", alpha=0.8)
ax1.set_xlabel("Distance (km)", fontsize=10)
ax1.set_ylabel("SNR (dB)",      fontsize=10)
ax1.set_title("Distance vs SNR\n(Path Loss Effect)", fontsize=11, fontweight="bold")
ax1.legend(fontsize=8); ax1.grid(True, ls="--", alpha=0.4)

# ── Panel 2 : SNR Distribution ───────────────────────────────
ax2 = fig.add_subplot(gs[0, 1])
ax2.hist(df["SNR_dB"], bins=30, color="#1f77b4", edgecolor="white")
ax2.axvline(SNR_THRESH_QPSK,  color="orange", lw=2, ls="--")
ax2.axvline(SNR_THRESH_16QAM, color="green",  lw=2, ls="--")
ax2.set_xlabel("SNR (dB)",  fontsize=10)
ax2.set_ylabel("Frequency", fontsize=10)
ax2.set_title("SNR Distribution", fontsize=11, fontweight="bold")
ax2.grid(True, ls="--", alpha=0.4)

# ── Panel 3 : SNR vs Modulation ──────────────────────────────
ax3 = fig.add_subplot(gs[0, 2])
for lbl in [0,1,2]:
    mask = labels == lbl
    ax3.scatter(df["SNR_dB"][mask], np.full(mask.sum(), lbl),
                alpha=0.4, s=10, color=COLORS[lbl], edgecolors="none")
ax3.set_yticks([0,1,2])
ax3.set_yticklabels(["QPSK","16-QAM","64-QAM"], fontsize=9)
ax3.axvline(SNR_THRESH_QPSK,  color="k", lw=1.2, ls="--", alpha=0.5)
ax3.axvline(SNR_THRESH_16QAM, color="k", lw=1.2, ls="--", alpha=0.5)
ax3.set_xlabel("SNR (dB)",         fontsize=10)
ax3.set_ylabel("Modulation Class", fontsize=10)
ax3.set_title("SNR vs Modulation Scatter", fontsize=11, fontweight="bold")
ax3.grid(True, ls="--", alpha=0.4)

# ── Panel 4 : Confusion Matrix ───────────────────────────────
ax4 = fig.add_subplot(gs[1, 0])
cm  = confusion_matrix(y_test, best_pred)
im  = ax4.imshow(cm, interpolation="nearest", cmap=plt.cm.Blues)
plt.colorbar(im, ax=ax4, fraction=0.046, pad=0.04)
ticks = np.arange(3)
ax4.set_xticks(ticks); ax4.set_yticks(ticks)
ax4.set_xticklabels(["QPSK","16-QAM","64-QAM"], fontsize=9, rotation=30)
ax4.set_yticklabels(["QPSK","16-QAM","64-QAM"], fontsize=9)
thresh = cm.max() / 2.0
for i in range(3):
    for j in range(3):
        ax4.text(j, i, f"{cm[i,j]}",
                 ha="center", va="center", fontsize=12,
                 color="white" if cm[i,j] > thresh else "black")
ax4.set_xlabel("Predicted Label", fontsize=10)
ax4.set_ylabel("True Label",      fontsize=10)
ax4.set_title(f"Confusion Matrix\n{best_name}  ({best_acc*100:.1f}%)",
              fontsize=11, fontweight="bold")

# ── Panel 5 : Model Comparison ───────────────────────────────
ax5 = fig.add_subplot(gs[1, 1])
bcolors = ["#d62728" if k == best_name else "#1f77b4" for k in model_names]
bars5 = ax5.bar(["RF","LR","SVM"],
                [rf_acc*100, lr_acc*100, svm_acc*100],
                color=bcolors, edgecolor="white", width=0.5)
ax5.set_ylim([0, 108])
ax5.set_ylabel("Test Accuracy (%)", fontsize=10)
ax5.set_title("Model Accuracy Comparison", fontsize=11, fontweight="bold")
ax5.grid(True, axis="y", ls="--", alpha=0.5)
for bar, acc in zip(bars5, [rf_acc*100, lr_acc*100, svm_acc*100]):
    ax5.text(bar.get_x()+bar.get_width()/2, acc+0.5,
             f"{acc:.1f}%", ha="center", va="bottom", fontsize=10,
             fontweight="bold")

# ── Panel 6 : Feature Importance ────────────────────────────
ax6 = fig.add_subplot(gs[1, 2])
sort_idx2 = np.argsort(rf_model.feature_importances_)[::-1]
ft_labels2 = np.array(["SNR", "Distance", "Noise"])[sort_idx2]
ft_vals2   = rf_model.feature_importances_[sort_idx2]
ax6.bar(ft_labels2, ft_vals2,
        color=["#1f77b4","#ff7f0e","#2ca02c"][:len(ft_vals2)],
        edgecolor="white")
ax6.set_ylabel("Feature Importance", fontsize=10)
ax6.set_title("Feature Importance\n(Random Forest)", fontsize=11, fontweight="bold")
ax6.set_ylim([0, 1.1])
for i, v in enumerate(ft_vals2):
    ax6.text(i, v+0.01, f"{v:.3f}", ha="center", fontsize=10)
ax6.grid(True, axis="y", ls="--", alpha=0.5)

fig.suptitle(
    "LTE/5G Adaptive Modulation  –  Machine Learning Summary Dashboard\n"
    f"Best Model: {best_name}  |  Test Accuracy: {best_acc*100:.1f}%  "
    f"|  N = {N} samples",
    fontsize=14, fontweight="bold"
)
plt.savefig("plot_J_summary_dashboard.png", dpi=150, bbox_inches="tight")
plt.show()
print("  Saved: plot_J_summary_dashboard.png\n")

# ============================================================
#  STEP 8 : LIVE PREDICTION DEMO
# ============================================================
print("─" * 40)
print(" STEP 8 : Live Prediction Demo")
print("─" * 40)

# Test cases covering each class and a boundary case
test_cases = [
    {"SNR_dB": 5.0,  "Distance": 4.0, "Noise_dBm": -95.0, "expected": "QPSK"},
    {"SNR_dB": 15.0, "Distance": 2.0, "Noise_dBm": -90.0, "expected": "16-QAM"},
    {"SNR_dB": 25.0, "Distance": 0.5, "Noise_dBm": -88.0, "expected": "64-QAM"},
    {"SNR_dB": 10.5, "Distance": 1.8, "Noise_dBm": -92.0, "expected": "16-QAM (boundary)"},
    {"SNR_dB": 18.0, "Distance": 2.5, "Noise_dBm": -90.0, "expected": "16-QAM (report demo)"},
]

print(f"{'SNR':>6}  {'Dist':>6}  {'Noise':>7}  {'Expected':<22} {'Predicted':<12} {'Match'}")
print("-" * 70)
for tc in test_cases:
    inp = pd.DataFrame([[tc["SNR_dB"], tc["Distance"], tc["Noise_dBm"]]],
                       columns=FEATURE_COLS)
    pred_label = best_model.predict(inp.values)[0]
    pred_name  = MOD_MAP[pred_label]
    match      = "✓" if pred_name in tc["expected"] else "✗"
    print(f"{tc['SNR_dB']:>6.1f}  {tc['Distance']:>6.2f}  {tc['Noise_dBm']:>7.1f}  "
          f"{tc['expected']:<22} {pred_name:<12} {match}")

# ============================================================
#  FINAL SUMMARY
# ============================================================
print("\n" + "=" * 56)
print("  SIMULATION COMPLETE")
print("=" * 56)
print(f"  Dataset          : {N} samples  |  {len(FEATURE_COLS)} features")
print(f"  Train / Test     : {len(X_train)} / {len(X_test)}")
print(f"  Random Forest    : {rf_acc*100:.2f}%  (5-fold CV: {rf_cv.mean()*100:.2f}%)")
print(f"  Logistic Regr.   : {lr_acc*100:.2f}%  (5-fold CV: {lr_cv.mean()*100:.2f}%)")
print(f"  SVM (RBF)        : {svm_acc*100:.2f}%  (5-fold CV: {svm_cv.mean()*100:.2f}%)")
print(f"  ── Best Model ──  {best_name}  →  {best_acc*100:.2f}%")
print()
print("  Output files generated:")
for fname in [
    "wireless_dataset.csv",
    "plot_A_distance_vs_snr.png",
    "plot_B_snr_distribution.png",
    "plot_C_snr_vs_modulation.png",
    "plot_D_distance_vs_modulation.png",
    "plot_E_noise_vs_modulation.png",
    "plot_F_confusion_matrix.png",
    "plot_G_model_comparison.png",
    "plot_H_feature_importance.png",
    "plot_I_decision_boundaries.png",
    "plot_J_summary_dashboard.png",
]:
    print(f"    {fname}")
print("=" * 56)
