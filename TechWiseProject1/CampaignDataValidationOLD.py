import requests
import pandas as pd
import base64
import logging
import json

# Setup logging
logging.basicConfig(filename='c:\\IBM\\feed.log',
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

# 1. Collect user inputs
feed_file_path = input("Enter the path to the csv feed file (Example: \\\\192.168.100.186\\dropoff\\2023\\APpName\\Appfeed.csv): ")
delimiter = input("Please specify the delimiter in the csv file. Example ; or , :")
report_file_path = input("Enter the path to the report file to compare to (Example: \\\\192.168.100.186\\Reports\\2023\\excel\\AppName-CampaignReport-2023.xlsx): ")
userid_col = input("Enter the name of the column in the feed representing the userid (Example: userid or samaccountname): ")
group_col = input("Enter the name of the column in the feed representing the entitlement (Example: Role or group): ")
appname = input("Enter the name of the application in IGI: ")
validation_report_path = input("Enter the path to save the validation report to (Example: \\\\192.168.100.186\\Reports\\2023\\excel\\AppName-Validation-Report-2023.xlsx): ")


# Generate the Base64 encoded credentials
user = "crossideas"
password = "CRI_srvpw@15"
credentials = f"{user}:{password}"
encoded_credentials = base64.b64encode(credentials.encode()).decode()

# 2. Authenticate to the IGI API
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
        #decoded_response = base64.b64decode(response.text).decode("utf-8")
        #logging.info("Decoded Server Response: " + decoded_response)
        # Parse the decoded string as JSON
        #json_response = json.loads(decoded_response)
        #key = decoded_response
        # key = response.json()["http.bodyAsString"]
    except ValueError:
        print("Error decoding JSON. Here's the server's response!!!:")
        print(response.text)

else:
    print(f"Request failed with status code {response.status_code}. Here's the server's response:")
    print(response.text)
    exit(1)


# 3. Read and process the CSV feed file using the user-specified delimiter
df_feed = pd.read_csv(feed_file_path, delimiter=delimiter)
logging.info("Read the CSV file ")
validation_results = []

for _, feed_row in df_feed.iterrows():
    group = str(feed_row[group_col])
    if group.startswith("Last Login"):
        continue

    # 4. Authenticate and get person_code from the API
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
        "filter": f'urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Account:code eq "{feed_row[userid_col]}" and urn:ibm:params:scim:schemas:resource:bean:agc:2.0:Account:pwdcfg_name eq "{appname}"'
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
    person_code = cleaned_json_content.get("person_code", None)

    logging.info("person_code: " + str(person_code))

    # 5. Validate against report
    logging.info("Validating against the report")
    df_report = pd.read_excel(report_file_path)
    matched_report = df_report[(df_report["UserID"] == person_code) & (df_report["Permission"] == group)]
    logging.info("-------------------------------------------------")
    if not matched_report.empty:
        matched_row = matched_report.iloc[0]
        validation_report = {
            "emp_network_id": feed_row[userid_col],
            "First Name": matched_row["First Name"],
            "Last_Name": matched_row["Last Name"],
            "Campaign": matched_row["Campaign"],
            "group": matched_row["Permission"],
            "Review Status": matched_row["Review Status"],
            "Reviewer": matched_row["Reviewer"],
            "match": True
        }
    else:
        validation_report = {
            "emp_network_id": feed_row[userid_col],
            "First Name": "",
            "Last_Name": "",
            "Campaign": "",
            "group": "",
            "Review Status": "",
            "Reviewer": "",
            "match": False
        }
    validation_results.append(validation_report)

# 6. Write validation report
df_validation_results = pd.DataFrame(validation_results)
df_validation_results.to_excel(validation_report_path, index=False)