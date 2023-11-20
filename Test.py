import openpyxl

def sort_and_remove_duplicates(xlsx_file):
  """Sorts an XLSX file in alphabetical order and removes duplicate rows.

  Args:
    xlsx_file: The path to the XLSX file.
  """

  # Load the XLSX file.
  wb = openpyxl.load_workbook(xlsx_file)

  # Get the active worksheet.
  ws = wb.active

  # Sort the worksheet in alphabetical order.
  ws.sort_values(column=1, inplace=True)

  # Remove duplicate rows.
  seen = set()
  for row in ws.rows:
    if tuple(row) in seen:
      ws.delete_rows(row.row)
    else:
      seen.add(tuple(row))

  # Save the worksheet.
  wb.save(xlsx_file)

if __name__ == '__main__':
  xlsx_file = 'C:\Scripts\Outputs\test.xlsx'
  sort_and_remove_duplicates(xlsx_file)
