'''
import pandas as pd
import openpyxl
import logging
import ibm_db
import ibm_db_dbi
import requests
import base64
import json

# Setup logging
logging.basicConfig(filename='c:\\IBM\\feed.log',
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

logging.info("Prompting user for campaign name")
campaign_name = input("Please enter name of the OPEN campaign you want to report on: ")

logging.info("Prompting user for path to destination excel file")
output_file = input("Please specify the path to save the Excel file report(Example: \\\\192.168.100.186\\Reports\\2023\\excel\\Name-Open-CampaignReport-2023.xlsx): ")

# Check if reporting of last Login is required
last_login = input("Does the report include last login date? (Y/N)")

# tdidb Connection Details
JDBC_URL_TDI = "DATABASE=tdidb;HOSTNAME=192.168.100.186;PORT=50000;PROTOCOL=TCPIP;UID=igiinst;PWD=FOx15APt64#;"
conn_tdi = ibm_db.connect(JDBC_URL_TDI, "", "")
pconn_tdi = ibm_db_dbi.Connection(conn_tdi)

# Load tdidb database with feed information for last login if needed
if last_login in ("Y", "y"):
    feed_file_path = input("Enter the path to the csv feed file (Example: \\\\192.168.100.186\\dropoff\\2023\\ImageCentre BCX\\FEED ImageCentre.csv): ")
    app_name = input("Enter the name of the application: ")
    last_login_col = input("Please enter the name of the column representing Last_Login_On: ")
    group_col = input("Enter the name of the column in the feed representing the entitlement (Example: Role): ")
    userid_col = input("Enter the name of the column in the feed representing the userid (Example: userid): ")
    delimiter = input("Please specify the delimiter in the csv file. Example ; or , :")

    def escape_single_quotes(value):
        return str(value).replace("'", "''")

    # Generate the Base64 encoded credentials
    user = "crossideas"
    password = "CRI_srvpw@15"
    credentials = f"{user}:{password}"
    encoded_credentials = base64.b64encode(credentials.encode()).decode()

    # Authenticate to the IGI API
    login_url = "https://isig.flushingbank.com:9343/igi/v2/security/login"
    headers = {
        "Authorization": f"Basic {encoded_credentials}",
        "content-type": "application/scim+json",
        "realm": "Admin"
    }
    response = requests.get(login_url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        try:
            key = response.text
            logging.info("Set KEY to: " + key)
            # Decode the entire server response from Base64
            # decoded_response = base64.b64decode(response.text).decode("utf-8")
            # logging.info("Decoded Server Response: " + decoded_response)
            # Parse the decoded string as JSON
            # json_response = json.loads(decoded_response)
            # key = decoded_response
            # key = response.json()["http.bodyAsString"]
        except ValueError:
            print("Error decoding JSON. Here's the server's response!!!:")
            print(response.text)

    else:
        print(f"Request failed with status code {response.status_code}. Here's the server's response:")
        print(response.text)
        exit(1)

    # Clear the WORK table
    try:
        ibm_db.exec_immediate(conn_tdi, 'DELETE FROM "WORK"')
    except Exception as e:
        logging.error("Error clearing the WORK table: " + str(e))

    # Read CSV data
    df_feed = pd.read_csv(feed_file_path, delimiter=delimiter)

    # Iterate and get person_code & insert to WORK table
    for _, row in df_feed.iterrows():
        # last_login_value = row[last_login_col]
        # group_value = row[group_col]
        # userid_value = row[userid_col]
        last_login_value = escape_single_quotes(row[last_login_col])
        group_value = escape_single_quotes(row[group_col])
        userid_value = escape_single_quotes(row[userid_col])

        # Authenticate and get person_code from the API
        logging.info("Getting PERSON CODE")
        api_url = "https://isig.flushingbank.com:9343/igi/v2/agc/users/accounts/.search?targetattributes=true"
        headers = {
            "realm": "Ideas",
            "content-type": "application/scim+json",
            "authorization": "Bearer " + key,
            "accept-Encoding": "UTF-8"
        }
        logging.info("HEADERS: " + str(headers))
        body = {
            "schemas": ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "filter": f'urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Account:code eq "{row[userid_col]}" and urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Account:pwdcfg_name eq "{app_name}"'
        }
        logging.info("BODY: " + str(body))
        response = requests.post(api_url, headers=headers, json=body)
        response.raise_for_status()

        logging.info("POST Response: " + str(response.text))

        response_text = response.text

        # Find the starting position of the substring "schemas" from position 30 onwards
        value = response_text.find("schemas", 30)
        if value != -1:  # -1 means "schemas" was not found
            value2 = value - 2
            line_length = len(response_text) - 2
            value3 = response_text[value2:line_length]
            logging.info("VALUE###: " + value3)
        else:
            logging.warning("The substring 'schemas' was not found in the response.")

        cleaned_json_content = json.loads(value3)  # This assumes value3 is a cleaned-up JSON string.
        pre_person_code = cleaned_json_content.get("person_code", None)
        person_code = escape_single_quotes(pre_person_code)

        logging.info("person_code: " + str(person_code))

        # Insert into WORK table
        insert_sql = f"""
                INSERT INTO WORK (APPLICATION, ACCOUNT, LASTLOGINON, ROLE, IDENTITY)
                VALUES ('{app_name}', '{userid_value}', '{last_login_value}', '{group_value}', '{person_code}')
                """
        ibm_db.exec_immediate(conn_tdi, insert_sql)
    logging.info("##### COMPLETED LOAD INTO TEMPORARY TDI DATABASE #####")
if last_login in ("N", "n"): 
    print("Proceeding without Last Log On data")

# Database Connection Details
JDBC_URL = "DATABASE=IGI_DB;HOSTNAME=192.168.100.186;PORT=50050;PROTOCOL=TCPIP;UID=igiinst;PWD=FOx15APt64#;"
conn = ibm_db.connect(JDBC_URL, "", "")
pconn = ibm_db_dbi.Connection(conn)

# Search ATTESTATION table
sql_attestation = f"SELECT START_DATE, ID FROM IGACORE.ATTESTATION WHERE NAME = '{campaign_name}'"
df_attestation = pd.read_sql(sql_attestation, pconn)
START_DATE = df_attestation.iloc[0]['START_DATE']
campaignID = df_attestation.iloc[0]['ID']
logging.info("ATTESTATION START_DATE: " + str(START_DATE))
logging.info("campaignID: " + str(campaignID))

# Search EMPLOYMENT_REVIEW table
sql_employment_review = f"SELECT * FROM IGACORE.EMPLOYMENT_REVIEW WHERE ATTESTATION = '{campaignID}'"
df_employment_reviews = pd.read_sql(sql_employment_review, pconn)
# REVIEW_DATE = df_employment_reviews.iloc[0]['REVIEW_DATE']
# logging.info("REVIEW_DATE: " + str(REVIEW_DATE))

# The report will be populated iteratively for each employment review
report_data = []

# Query TDI database for last login value
def get_last_login_for_user(person_code):
    try:
        sql_query = f"SELECT LASTLOGINON FROM WORK WHERE IDENTITY='{person_code}'"
        df_last_login = pd.read_sql(sql_query, pconn_tdi)
        if df_last_login.empty:
            return ""
        return df_last_login.iloc[0]['LASTLOGINON']
    except Exception as e:
        logging.error(f"Error fetching last login for person code {person_code}: {e}")
        return ""

for _, review_row in df_employment_reviews.iterrows():
    # Variables for this employment review
    PERSON_ID = review_row['PERSON']
    hierarchyID = review_row['ID']
    ENTITLEMENT_CODE = review_row['ENTITLEMENT']
    REVIEW_STATE = review_row['REVIEW_STATE']
    REVIEW_DATE = review_row['REVIEW_DATE']
    logging.info("ENTITLEMENT_CODE: " + str(ENTITLEMENT_CODE))
    logging.info("REVIEW_STATE: " + str(REVIEW_STATE))
    logging.info("REVIEW_DATE: " + str(REVIEW_DATE))

    # Logic for Review Status

    state = str(REVIEW_STATE)[0]
    logging.info("state: " + state)

    if state == "0":
        Review_Status = "Not certified"
    elif state in ["1", "2", "3"]:
        Review_Status = "Approved" if state == "1" else "Revoked"
    else:
        Review_Status = "Other"

    logging.info("Review_Status: " + Review_Status)
    # Query for ENTITLEMENT
    sql_entitlement = f"SELECT NAME, APPLICATION FROM IGACORE.ENTITLEMENT WHERE ID = '{ENTITLEMENT_CODE}'"
    df_entitlement = pd.read_sql(sql_entitlement, pconn)
    Permission = df_entitlement.iloc[0]['NAME']
    APPLICATIONID = df_entitlement.iloc[0]['APPLICATION']
    logging.info("Permission: " + str(Permission))
    if Permission.startswith("Last Login"):
        continue

    # Query for APPLICATION
    sql_application = f"SELECT NAME FROM IGACORE.APPLICATION WHERE ID = '{APPLICATIONID}'"
    df_application = pd.read_sql(sql_application, pconn)
    Application = df_application.iloc[0]['NAME']
    logging.info("Application: " + str(Application))

    # Query for PERSON
    sql_person = f"SELECT EMAIL, USER_ERC, CODE, NAME, SURNAME, ORGANIZATIONAL_UNIT FROM IGACORE.PERSON WHERE ID = '{PERSON_ID}'"
    df_person = pd.read_sql(sql_person, pconn)
    EMAIL = df_person.iloc[0]['EMAIL']
    UserID = df_person.iloc[0]['CODE']
    First_Name = df_person.iloc[0]['NAME']
    Last_Name = df_person.iloc[0]['SURNAME']
    orgUnitID = df_person.iloc[0]['ORGANIZATIONAL_UNIT']
    USER_ERC = df_person.iloc[0]['USER_ERC']  # This is from the Person search
    logging.info("EMAIL: " + str(EMAIL))
    logging.info("UserID: " + str(UserID))
    logging.info("First_Name: " + str(First_Name))
    logging.info("Last_Name: " + str(Last_Name))
    logging.info("orgUnitID: " + str(orgUnitID))
    logging.info("USER_ERC: " + str(USER_ERC))

    # Query for ORGANIZATIONAL_UNIT
    sql_org_unit = f"SELECT NAME FROM IGACORE.ORGANIZATIONAL_UNIT WHERE ID = '{orgUnitID}'"
    df_org_unit = pd.read_sql(sql_org_unit, pconn)
    Org_Unit = df_org_unit.iloc[0]['NAME']
    logging.info("Org_Unit: " + str(Org_Unit))

    # Query for USER_ERC
    sql_user_erc = f"SELECT ATTR1, DISABLED FROM IGACORE.USER_ERC WHERE ID = '{USER_ERC}'"
    df_user_erc = pd.read_sql(sql_user_erc, pconn)
    ReviewerID = df_user_erc.iloc[0]['ATTR1']
    User_Status = "DISABLED" if df_user_erc.iloc[0]['DISABLED'] == 1 else "ACTIVE"
    logging.info("ReviewerID: " + str(ReviewerID))

    # Query for ATTESTATION: CERT_FIRST_OWNER_NAME and CERT_FIRST_OWNER_SURNAME
    sql_reviewer = f"SELECT NAME, SURNAME FROM IGACORE.PERSON WHERE UPPER(CODE) = UPPER('{ReviewerID}')"
    df_reviewer = pd.read_sql(sql_reviewer, pconn)
    CERT_FIRST_OWNER_NAME = df_reviewer.iloc[0]['NAME']
    CERT_FIRST_OWNER_SURNAME = df_reviewer.iloc[0]['SURNAME']
    logging.info("CERT_FIRST_OWNER_NAME: " + str(CERT_FIRST_OWNER_NAME))
    logging.info("CERT_FIRST_OWNER_SURNAME: " + str(CERT_FIRST_OWNER_SURNAME))
    logging.info("----------------------------------------------")

    # Logic for the last login date
    last_login_date = ""
    if last_login in ("Y", "y"):
        last_login_date = get_last_login_for_user(UserID)  # Using UserID as the person_code based on the previous code provided.
        # Prepare a row for the final report
        report_row = {
            "Application": Application,
            "Campaign": campaign_name,
            "Campaign Start": START_DATE,
            "First Name": First_Name,
            "Last Name": Last_Name,
            "UserID": UserID,
            "EMAIL": EMAIL,
            "User Status": User_Status,
            "Org_Unit": Org_Unit,
            "Permission": Permission,
            "Review Status": Review_Status,
            "Reviewer": f"{CERT_FIRST_OWNER_NAME} {CERT_FIRST_OWNER_SURNAME}",
            "ReviewerID": ReviewerID,
            "Review Date": REVIEW_DATE,
            "Last Login On": last_login_date
        }
        report_data.append(report_row)
        print(_, review_row)
    
    if last_login in ("N", "n"):    
        # Prepare a row for the final report
        report_row = {
            "Application": Application,
            "Campaign": campaign_name,
            "Campaign Start": START_DATE,
            "First Name": First_Name,
            "Last Name": Last_Name,
            "UserID": UserID,
            "EMAIL": EMAIL,
            "User Status": User_Status,
            "Org_Unit": Org_Unit,
            "Permission": Permission,
            "Review Status": Review_Status,
            "Reviewer": f"{CERT_FIRST_OWNER_NAME} {CERT_FIRST_OWNER_SURNAME}",
            "ReviewerID": ReviewerID,
            "Review Date": REVIEW_DATE
        }
        report_data.append(report_row)
        #print(_, review_row)

# Convert the list of dictionaries to a pandas DataFrame
df_report = pd.DataFrame(report_data)

# Saving to Excel
df_report.to_excel(output_file, index=False)
print(f"Report saved to {output_file}")
logging.info("Wrote file to: " + output_file)


ibm_db.close(conn)
ibm_db.close(conn_tdi)
'''
import pandas as pd
import openpyxl
import logging
import ibm_db
import ibm_db_dbi
import requests
import base64
import json

# Setup logging
logging.basicConfig(filename='c:\\IBM\\feed.log',
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

logging.info("Prompting user for campaign name")
campaign_name = input("Please enter name of the OPEN campaign you want to report on: ")

logging.info("Prompting user for path to destination excel file")
output_file = input("Please specify the path to save the Excel file report: ")

# Check if reporting of last Login is required
last_login = input("Does the report include last login date? (Y/N)")

# tdidb Connection Details
JDBC_URL_TDI = "DATABASE=tdidb;HOSTNAME=192.168.100.186;PORT=50000;PROTOCOL=TCPIP;UID=igiinst;PWD=FOx15APt64#;"
conn_tdi = ibm_db.connect(JDBC_URL_TDI, "", "")
pconn_tdi = ibm_db_dbi.Connection(conn_tdi)

# Load tdidb database with feed information for last login if needed
if last_login == "Y":
    feed_file_path = input("Enter the path to the csv feed file (Example: C:\IBM\Alloyfeed.csv): ")
    app_name = input("Enter the name of the application: ")
    last_login_col = input("Please enter the name of the column representing Last_Login_On: ")
    group_col = input("Enter the name of the column in the feed representing the entitlement (Example: Role): ")
    userid_col = input("Enter the name of the column in the feed representing the userid (Example: userid): ")
    delimiter = input("Please specify the delimiter in the csv file. Example ; or , :")

    def escape_single_quotes(value):
        return str(value).replace("'", "''")

    # Generate the Base64 encoded credentials
    user = "crossideas"
    password = "CRI_srvpw@15"
    credentials = f"{user}:{password}"
    encoded_credentials = base64.b64encode(credentials.encode()).decode()

    # Authenticate to the IGI API
    login_url = "https://isig.flushingbank.com:9343/igi/v2/security/login"
    headers = {
        "Authorization": f"Basic {encoded_credentials}",
        "content-type": "application/scim+json",
        "realm": "Admin"
    }
    response = requests.get(login_url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        try:
            key = response.text
            logging.info("Set KEY to: " + key)
            # Decode the entire server response from Base64
            # decoded_response = base64.b64decode(response.text).decode("utf-8")
            # logging.info("Decoded Server Response: " + decoded_response)
            # Parse the decoded string as JSON
            # json_response = json.loads(decoded_response)
            # key = decoded_response
            # key = response.json()["http.bodyAsString"]
        except ValueError:
            print("Error decoding JSON. Here's the server's response!!!:")
            print(response.text)

    else:
        print(f"Request failed with status code {response.status_code}. Here's the server's response:")
        print(response.text)
        exit(1)

    # Clear the WORK table
    try:
        ibm_db.exec_immediate(conn_tdi, 'DELETE FROM "WORK"')
    except Exception as e:
        logging.error("Error clearing the WORK table: " + str(e))

    # Read CSV data
    df_feed = pd.read_csv(feed_file_path, delimiter=delimiter)

    # Iterate and get person_code & insert to WORK table
    for _, row in df_feed.iterrows():
        # last_login_value = row[last_login_col]
        # group_value = row[group_col]
        # userid_value = row[userid_col]
        last_login_value = escape_single_quotes(row[last_login_col])
        group_value = escape_single_quotes(row[group_col])
        userid_value = escape_single_quotes(row[userid_col])

        # Authenticate and get person_code from the API
        logging.info("Getting PERSON CODE")
        api_url = "https://isig.flushingbank.com:9343/igi/v2/agc/users/accounts/.search?targetattributes=true"
        headers = {
            "realm": "Ideas",
            "content-type": "application/scim+json",
            "authorization": "Bearer " + key,
            "accept-Encoding": "UTF-8"
        }
        logging.info("HEADERS: " + str(headers))
        body = {
            "schemas": ["urn:ietf:params:scim:api:messages:2.0:SearchRequest"],
            "filter": f'urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Account:code eq "{row[userid_col]}" and urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Account:pwdcfg_name eq "{app_name}"'
        }
        logging.info("BODY: " + str(body))
        response = requests.post(api_url, headers=headers, json=body)
        response.raise_for_status()

        logging.info("POST Response: " + str(response.text))

        response_text = response.text

        # Find the starting position of the substring "schemas" from position 30 onwards
        value = response_text.find("schemas", 30)
        if value != -1:  # -1 means "schemas" was not found
            value2 = value - 2
            line_length = len(response_text) - 2
            value3 = response_text[value2:line_length]
            logging.info("VALUE###: " + value3)
        else:
            logging.warning("The substring 'schemas' was not found in the response.")

        cleaned_json_content = json.loads(value3)  # This assumes value3 is a cleaned-up JSON string.
        pre_person_code = cleaned_json_content.get("person_code", None)
        person_code = escape_single_quotes(pre_person_code)

        logging.info("person_code: " + str(person_code))

        # Insert into WORK table
        insert_sql = f"""
                INSERT INTO WORK (APPLICATION, ACCOUNT, LASTLOGINON, ROLE, IDENTITY)
                VALUES ('{app_name}', '{userid_value}', '{last_login_value}', '{group_value}', '{person_code}')
                """
        ibm_db.exec_immediate(conn_tdi, insert_sql)
    logging.info("##### COMPLETED LOAD INTO TEMPORARY TDI DATABASE #####")


# Database Connection Details
JDBC_URL = "DATABASE=IGI_DB;HOSTNAME=192.168.100.186;PORT=50050;PROTOCOL=TCPIP;UID=igiinst;PWD=FOx15APt64#;"
conn = ibm_db.connect(JDBC_URL, "", "")
pconn = ibm_db_dbi.Connection(conn)

# Search ATTESTATION table
sql_attestation = f"SELECT START_DATE, ID FROM IGACORE.ATTESTATION WHERE NAME = '{campaign_name}'"
df_attestation = pd.read_sql(sql_attestation, pconn)
START_DATE = df_attestation.iloc[0]['START_DATE']
campaignID = df_attestation.iloc[0]['ID']
logging.info("ATTESTATION START_DATE: " + str(START_DATE))
logging.info("campaignID: " + str(campaignID))

# Search EMPLOYMENT_REVIEW table
sql_employment_review = f"SELECT * FROM IGACORE.EMPLOYMENT_REVIEW WHERE ATTESTATION = '{campaignID}'"
df_employment_reviews = pd.read_sql(sql_employment_review, pconn)
# REVIEW_DATE = df_employment_reviews.iloc[0]['REVIEW_DATE']
# logging.info("REVIEW_DATE: " + str(REVIEW_DATE))

# The report will be populated iteratively for each employment review
report_data = []

# Query TDI database for last login value
def get_last_login_for_user(person_code):
    try:
        sql_query = f"SELECT LASTLOGINON FROM WORK WHERE IDENTITY='{person_code}'"
        df_last_login = pd.read_sql(sql_query, pconn_tdi)
        if df_last_login.empty:
            return ""
        return df_last_login.iloc[0]['LASTLOGINON']
    except Exception as e:
        logging.error(f"Error fetching last login for person code {person_code}: {e}")
        return ""

for _, review_row in df_employment_reviews.iterrows():
    # Variables for this employment review
    PERSON_ID = review_row['PERSON']
    hierarchyID = review_row['ID']
    ENTITLEMENT_CODE = review_row['ENTITLEMENT']
    REVIEW_STATE = review_row['REVIEW_STATE']
    REVIEW_DATE = review_row['REVIEW_DATE']
    logging.info("ENTITLEMENT_CODE: " + str(ENTITLEMENT_CODE))
    logging.info("REVIEW_STATE: " + str(REVIEW_STATE))
    logging.info("REVIEW_DATE: " + str(REVIEW_DATE))

    # Logic for Review Status

    state = str(REVIEW_STATE)[0]
    logging.info("state: " + state)

    if state == "0":
        Review_Status = "Not certified"
    elif state in ["1", "2", "3"]:
        Review_Status = "Approved" if state == "1" else "Revoked"
    else:
        Review_Status = "Other"

    logging.info("Review_Status: " + Review_Status)
    # Query for ENTITLEMENT
    sql_entitlement = f"SELECT NAME, APPLICATION FROM IGACORE.ENTITLEMENT WHERE ID = '{ENTITLEMENT_CODE}'"
    df_entitlement = pd.read_sql(sql_entitlement, pconn)
    Permission = df_entitlement.iloc[0]['NAME']
    APPLICATIONID = df_entitlement.iloc[0]['APPLICATION']
    logging.info("Permission: " + str(Permission))
    if Permission.startswith("Last Login"):
        continue

    # Query for APPLICATION
    sql_application = f"SELECT NAME FROM IGACORE.APPLICATION WHERE ID = '{APPLICATIONID}'"
    df_application = pd.read_sql(sql_application, pconn)
    Application = df_application.iloc[0]['NAME']
    logging.info("Application: " + str(Application))

    # Query for PERSON
    sql_person = f"SELECT EMAIL, USER_ERC, CODE, NAME, SURNAME, ORGANIZATIONAL_UNIT FROM IGACORE.PERSON WHERE ID = '{PERSON_ID}'"
    df_person = pd.read_sql(sql_person, pconn)
    EMAIL = df_person.iloc[0]['EMAIL']
    UserID = df_person.iloc[0]['CODE']
    First_Name = df_person.iloc[0]['NAME']
    Last_Name = df_person.iloc[0]['SURNAME']
    orgUnitID = df_person.iloc[0]['ORGANIZATIONAL_UNIT']
    USER_ERC = df_person.iloc[0]['USER_ERC']  # This is from the Person search
    logging.info("EMAIL: " + str(EMAIL))
    logging.info("UserID: " + str(UserID))
    logging.info("First_Name: " + str(First_Name))
    logging.info("Last_Name: " + str(Last_Name))
    logging.info("orgUnitID: " + str(orgUnitID))
    logging.info("USER_ERC: " + str(USER_ERC))

    # Query for ORGANIZATIONAL_UNIT
    sql_org_unit = f"SELECT NAME FROM IGACORE.ORGANIZATIONAL_UNIT WHERE ID = '{orgUnitID}'"
    df_org_unit = pd.read_sql(sql_org_unit, pconn)
    Org_Unit = df_org_unit.iloc[0]['NAME']
    logging.info("Org_Unit: " + str(Org_Unit))

    # Query for USER_ERC
    sql_user_erc = f"SELECT ATTR1, DISABLED FROM IGACORE.USER_ERC WHERE ID = '{USER_ERC}'"
    df_user_erc = pd.read_sql(sql_user_erc, pconn)
    ReviewerID = df_user_erc.iloc[0]['ATTR1']
    User_Status = "DISABLED" if df_user_erc.iloc[0]['DISABLED'] == 1 else "ACTIVE"
    logging.info("ReviewerID: " + str(ReviewerID))

    # Query for ATTESTATION: CERT_FIRST_OWNER_NAME and CERT_FIRST_OWNER_SURNAME
    sql_reviewer = f"SELECT NAME, SURNAME FROM IGACORE.PERSON WHERE UPPER(CODE) = UPPER('{ReviewerID}')"
    df_reviewer = pd.read_sql(sql_reviewer, pconn)
    CERT_FIRST_OWNER_NAME = df_reviewer.iloc[0]['NAME']
    CERT_FIRST_OWNER_SURNAME = df_reviewer.iloc[0]['SURNAME']
    logging.info("CERT_FIRST_OWNER_NAME: " + str(CERT_FIRST_OWNER_NAME))
    logging.info("CERT_FIRST_OWNER_SURNAME: " + str(CERT_FIRST_OWNER_SURNAME))
    logging.info("----------------------------------------------")

    # Logic for the last login date
    last_login_date = ""
    if last_login == "Y":
        last_login_date = get_last_login_for_user(
            UserID)  # Using UserID as the person_code based on the previous code provided.

    # Prepare a row for the final report
    report_row = {
        "Application": Application,
        "Campaign": campaign_name,
        "Campaign Start": START_DATE,
        "First Name": First_Name,
        "Last Name": Last_Name,
        "UserID": UserID,
        "EMAIL": EMAIL,
        "User Status": User_Status,
        "Org_Unit": Org_Unit,
        "Permission": Permission,
        "Review Status": Review_Status,
        "Reviewer": f"{CERT_FIRST_OWNER_NAME} {CERT_FIRST_OWNER_SURNAME}",
        "ReviewerID": ReviewerID,
        "Review Date": REVIEW_DATE,
        "Last Login On": last_login_date
    }
    report_data.append(report_row)

# Convert the list of dictionaries to a pandas DataFrame
df_report = pd.DataFrame(report_data)

# Saving to Excel
df_report.to_excel(output_file, index=False)
print(f"Report saved to {output_file}")
logging.info("Wrote file to: " + output_file)


ibm_db.close(conn)
ibm_db.close(conn_tdi)
