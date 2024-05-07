import pandas as pd

# Load the Excel file into a DataFrame
df = pd.read_excel("C:\Scripts\OutputFiles\AllUsers.xlsx")  # Replace with your file path

# Select the desired columns as object arrays
dn_array = df["Display Last Name"]
ln_array = df["LastName"]

# Create a new column to mark matches
#df["TEST"] = False

# Iterate through the values in col1_array
for i, value1 in enumerate(dn_array):
    for j, value2 in enumerate(ln_array):
    # Check if the value exists in col2_array
        if value1 == value2:
            df.loc[j, "TEST"] = True
            df.loc[j, "Phone"] = df.loc[i, "Mobile Phone"]
            print(value1,i," ",value2,j)
            break

# Save the modified DataFrame
df.to_excel("C:\Scripts\OutputFiles\modified_excel_file.xlsx", index=False)  # Replace with your desired output file
