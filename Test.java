import java.io.File;
import java.io.FileReader;
import java.io.PrintStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;

class Test{
//Reads a CSV file with 2 Columns exported from Azure VMs. Seperates into Array List and gets called to read and assigned to Resource Group and VM Name
//Then spits out a Text File that contains Code runnable in Azure Terminal
public static ArrayList<String[]> readCSVFile(String filePath) throws IOException {
    ArrayList<String[]> rows = new ArrayList<>(); //Creates an Array List of Strings containging each row of Data (stored as memory index)
    BufferedReader reader = new BufferedReader(new FileReader(filePath)); 
    String line;
    while ((line = reader.readLine()) != null) {
        String[] row = line.split(",");
        //System.out.println(line); //Test to show read line
        rows.add(row);
    }
    reader.close();
    return rows;
}
public static ArrayList<String> getValuesToPrintOutInMain(ArrayList<String[]> rows) {
    ArrayList<String> valuesToPrintOut = new ArrayList<>(); //Creates Array List of Values
    for (String[] row : rows) { 
        for (String value : row) {
            valuesToPrintOut.add(value);
            //System.out.println(value); //Test to show Value grabbed
        }
    }
    return valuesToPrintOut;
}

  public static void main(String[] args) throws IOException{

    //Creates File object that points to txt file
    PrintStream p = new PrintStream(new File("C:\\Scripts\\Test.txt"));
    //Stores Ssytem.out value to console
    PrintStream console = System.out;
    //Assigns output stream to p
    System.setOut(p); //Comment out this line to view in System.out

    String filePath = "C:\\Scripts\\Test.csv";
    ArrayList<String[]> rows = readCSVFile(filePath);
    ArrayList<String> valuesToPrintOut = getValuesToPrintOutInMain(rows);

    for (int i=2; i< valuesToPrintOut.size(); i = i+2) {
        String name = valuesToPrintOut.get(i);
        String resourcegroup = valuesToPrintOut.get(i+1);
        //System.out.println(name + " " + resourcegroup); //Prints which name and resource group it is working on

        System.out.println("$VM = Get-AzVM -ResourceGroupName " + resourcegroup + " -Name " + name);
        System.out.println("Stop-AzVM -ResourceGroupName " + resourcegroup + " -Name " + name +" -Force");
        System.out.println("Update-AzVM -VM $VM -ResourceGroupName "+ resourcegroup +" -EncryptionAtHost $true");
        System.out.println("Start-AzVM -ResourceGroupName " + resourcegroup + " -Name " + name);
        //$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
        //Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force
        //Update-AzVM -VM $VM -ResourceGroupName $ResourceGroupName -EncryptionAtHost $true
        //Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
    }

    String end = "Print to Text Completed";
    
    //Assings output stream back to console for display of what was printed
    System.setOut(console);
    System.out.println(end);
    //System.out.println(valuesToPrintOut.get(2));
  }
}