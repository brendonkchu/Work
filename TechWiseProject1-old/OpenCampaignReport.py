import pandas as pd
import openpyxl
import logging
import ibm_db
import ibm_db_dbi

# Setup logging
logging.basicConfig(filename='c:\\IBM\\feed.log',
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

logging.info("Prompting user for campaign name")
campaign_name = input("Please enter name of the OPEN campaign you want to report on: ")

logging.info("Prompting user for path to destination excel file")
output_file = input("Please specify the path to save the Excel file: ")

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
        "Last Login On": ""
    }
    report_data.append(report_row)

# Convert the list of dictionaries to a pandas DataFrame
df_report = pd.DataFrame(report_data)

# Saving to Excel
df_report.to_excel(output_file, index=False)
print(f"Report saved to {output_file}")
logging.info("Wrote file to: " + output_file)