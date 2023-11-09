import pandas as pd
import openpyxl
import logging
from ldap3 import Server, Connection, ALL
import subprocess
import sys

# Setup logging to file
logging.basicConfig(filename='c:\\IBM\\feed.log',       # Name of the log file
                    level=logging.INFO,       # Minimum logging level to write to the file
                    format='%(asctime)s - %(levelname)s - %(message)s',  # Format of log messages
                    datefmt='%Y-%m-%d %H:%M:%S')  # Date format

# Decide whether to use this script or another based on application name
app_name = "RemoteLender" #input("Please enter the name of the application in IGI: ")

if app_name == "Pentana":
    subprocess.Popen([sys.executable, 'Pentana.py'])
    print(f"Pentana uses a custom script for processing. This script made an attempt to run it before ending. If it didn't run try to run it directly")
    sys.exit()



# Prompt the user for the Excel file's source and destination locations
logging.info("Prompt the user for the Excel file's source and destination locations")
source_file = "\\\\192.168.100.186\\dropoff\\2023\\Remote Lender\\Remote Lender User Report.xlsx" #input("Please enter the source Excel file location (e.g., \\\\192.168.100.186\\dropoff\\2023\\AppName\\FileName.xlsx): ")
destination_file = "\\\\192.168.100.186\\dropoff\\2023\\Remote Lender\\FEED2-Remote Lender User Report.csv"#input("Please enter the destination CSV file location (e.g., C:\\IBM\\file2.csv): ")
logging.info("Source file: " + source_file)
logging.info("Destination file: " + destination_file)

# Function to handle potential no-input scenarios
def get_input(prompt):
    value = input(prompt)
    return value if value else None

# Prompt the user for the attribute names
email_col = "Email" #get_input("Please enter the name of the column representing Email Address: ")
first_name_col = "First Name" #get_input("Please enter the name of the column representing First Name: ")
last_name_col = "Last Nam" #get_input("Please enter the name of the column representing Last Name: ")
group_col = "Roles" #get_input("Please enter the name of the column representing Group: ")
userid_col = "Email" #get_input("Please enter the name of the column representing the userid: ")
full_name_col = "" #get_input("Please enter the name of the column representing the full name: ")
last_login = "Y" #get_input("Does this report include Last Login data? (Y/N) ")


if last_login.upper() == "Y":
    last_login_col = "Last Login" #get_input("Please enter the name of the column representing Last_Login_On: ")


# Read the Excel file
logging.info("Reading the Excel file")
df = pd.read_excel(source_file)

# Set up LDAP connection
server = Server('flushingsavings.com', use_ssl=False, get_info=ALL)
conn = Connection(server, 'flushingsavings\\crossideas', 'CRI_srvpw@15', auto_bind=True)
logging.info("Set up LDAP connection")

# Base DN
base_dn = 'OU=FSB,DC=flushingsavings,DC=com'
logging.info("Set base dn to: " + base_dn)

# Function to retrieve samaccountname from AD
def get_samaccountname(email):
    if email is None or email == '':
        return None
    search_filter = f"(proxyAddresses=smtp:{email})"
    conn.search(base_dn, search_filter, attributes=['samaccountname'])
    if conn.entries and str(conn.entries[0]['samaccountname']) not in [None, "[]"]:
        return str(conn.entries[0]['samaccountname'])
    else:
        return None

# Empty list to store expanded rows
expanded_rows = []

# Iterate over each row in the dataframe
for index, row in df.iterrows():
    groups = str(row.get(group_col, '')).split('\n')
    email = row.get(email_col, None)

    if last_login.upper() == "Y":
        last_login_date = f"Last Login On: {row.get(last_login_col, '')}"
    else:
        last_login_date = None

    # Diagnostic logging
    logging.info(f"Row {index} Email value: '{email}' Type: {type(email)}")

    first_name = row.get(first_name_col, '')
    last_name = row.get(last_name_col, '')
    full_name = row.get(full_name_col, '')

    if pd.isna(full_name) or full_name == '':
        full_name = f"{first_name} {last_name}"
        logging.info("changing full_name based on first and last: " + full_name)

    # Check for NaN values
    if pd.isna(email) or email == '':
        samaccountname = f"{full_name}"
        logging.info("Email is missing. Set samaccountname to: " + samaccountname)
    else:
        samaccountname = get_samaccountname(email)

        if not samaccountname:
            samaccountname = email

    for group in groups:
        new_row = {'Email Address': email,
                   'First Name': first_name,
                   'Last Name': last_name,
                   'Full Name': full_name,
                   'group': group,
                   'userid': row.get(userid_col, ''),
                   'samaccountname': samaccountname,
                   'Last Login On': last_login_date}
        expanded_rows.append(new_row)

        if last_login.upper() == "Y":
            login_time = row.get(last_login_col, '')
            entitlement_row = {'Email Address': email,
                               'First Name': first_name,
                               'Last Name': last_name,
                               'Full Name': full_name,
                               #'group': f"Last Login On: {row.get(last_login_col, '')}",
                               'group': f"Last Login On for {row.get(userid_col, '')}: {row.get(last_login_col, '')}",
                               'userid': row.get(userid_col, ''),
                               'samaccountname': samaccountname,
                               'Last Login On': last_login_date}
            expanded_rows.append(entitlement_row)
            print(entitlement_row)

# Create a new DataFrame from expanded rows
expanded_df = pd.DataFrame(expanded_rows)

# Remove the specified character sequence from the 'group' column
expanded_df['group'] = expanded_df['group'].str.replace('_x000D_', '', regex=False)

# Write to CSV
expanded_df.to_csv(destination_file, sep=';', index=False)