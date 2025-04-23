import matplotlib.pyplot as plt
import pandas as pd
import sys

# Read data from CSV file
data_file = sys.argv[1]
data = pd.read_csv(data_file)

# Create plots
plt.figure(figsize=(12, 6))

# Plot 1: Cell Count vs. Wire Count
plt.subplot(1, 2, 1)
plt.plot(data["Cells"], data["Wires"], marker="o", linestyle="-", color="b", label="Cells vs. Wires")
plt.xlabel("Number of Cells")
plt.ylabel("Number of Wires")
plt.title("Cell Count vs. Wire Count")
plt.legend()
plt.grid(True)

# Plot 2: Timing vs. Area
plt.subplot(1, 2, 2)
plt.plot(data["Timing"], data["Area"], marker="o", linestyle="-", color="r", label="Timing vs. Area")
plt.xlabel("Timing (ns)")
plt.ylabel("Area (µm²)")
plt.title("Timing vs. Area")
plt.legend()
plt.grid(True)

# Show the plots
plt.tight_layout()
plt.show()
