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
  xlsx_file = 'C:\\Scripts\\Outputs\\Test.xlsx'
  sort_and_remove_duplicates(xlsx_file)

#<script type="text/javascript">
  (function(w, d, x, id){
    s=d.createElement('script');
    s.src='https://db08fjupg2abb.cloudfront.net/amazon-connect-chat-interface-client.js';
    s.async=1;
    s.id=id;
    d.getElementsByTagName('head')[0].appendChild(s);
    w[x] =  w[x] || function() { (w[x].ac = w[x].ac || []).push(arguments) };
  })(window, document, 'amazon_connect', 'c527958c-f577-4cdc-bfb0-5280c1188b19');
  amazon_connect('styles', { iconType: 'CHAT', openChat: { color: '#000000', backgroundColor: '#ffffff' }, closeChat: { color: '#000000', backgroundColor: '#ffffff'} });
  amazon_connect('snippetId', 'QVFJREFIZ2JTNzdvNlZBdTFZSVJkT0xad3RDb08wM2NZamVYWno2UE4rbHpYL2JuRlFHa3pqVnVyZlhIeUk5dGFlUEZua1RmQUFBQWJqQnNCZ2txaGtpRzl3MEJCd2FnWHpCZEFnRUFNRmdHQ1NxR1NJYjNEUUVIQVRBZUJnbGdoa2dCWlFNRUFTNHdFUVFNOGdNN1UvYzNmOW9DTjB5a0FnRVFnQ3ZFOXFzdVpJcXlHdFJMSjNMRStTbUN2cXdoaWhDclNZNFc2RHRxYnczVTd0czdtN1lQRkhCVDRoeU46OmtFZVBZR1dtbHkvVk5SNnZHd05UM0ZuUUthbnN1aTBTV1oxdnROQm1La2swTGl3THZWbkMxcG9PSVkwT1d1ZjJ0aTFZUDR6MUNoZ0l4dUpJZlpPaDVjclB2UmVRR0s2NEtHakpRYmlTYU9yMFFIU1VsTTNyTVVqRndOZjR4QXU0Ym8vWUx1TElIdTYyUUhNZ1VKSG9YVTQ2akkyT013cz0=');
  amazon_connect('supportedMessagingContentTypes', [ 'text/plain', 'text/markdown' ]);
</script>