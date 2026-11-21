import os
import pandas as pd
folder_path = "data"
files = os.listdir(folder_path)
for file in files:
    if file.endswith(".csv"):
        print("FILE NAME:", file)
        df = pd.read_csv(f"{folder_path}/{file}", encoding="latin1")       
        print("Rows and Columns:", df.shape)
        print("\nMissing Values:")
        print(df.isnull().sum())
        print("\nDuplicate Rows:", df.duplicated().sum())
        print("===============\n")
print("EDA Inspection Complete!")