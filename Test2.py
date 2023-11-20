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

# tdidb Connection Details
JDBC_URL_TDI = "DATABASE=tdidb;HOSTNAME=192.168.100.186;PORT=50000;PROTOCOL=TCPIP;UID=igiinst;PWD=FOx15APt64#;"
conn_tdi = ibm_db.connect(JDBC_URL_TDI, "", "")
pconn_tdi = ibm_db_dbi.Connection(conn_tdi)

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
