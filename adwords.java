import java.io.BufferedReader;
import java.io.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class adwords {

    public static void main(String[] args) 
	throws SQLException, IOException, InterruptedException {

	System.out.println("Started");
    
//----------Creating Output Files for each task---------
	PrintWriter writer = new PrintWriter("system.out.1");
	writer = new PrintWriter("system.out.2");
	writer = new PrintWriter("system.out.3");
	writer = new PrintWriter("system.out.4");
	writer = new PrintWriter("system.out.5");
	writer = new PrintWriter("system.out.6");

//------------------------------------------
     //   PreparedStatement prest;
	CallableStatement cstmt;
        
        ArrayList<String> input = new ArrayList<String>();
        ArrayList<Integer> k = new ArrayList<Integer>();
                
        BufferedReader br = new BufferedReader(new FileReader("system.in"));
	
	String line = "";
                
	int ch;
	while ((line = br.readLine()) != null) {
	    ch = line.indexOf('=');
            input.add(line.substring(ch+2));
        }
                
        for (int i = 2; i<=7;i++ )
	    k.add(Integer.parseInt(input.get(i))); 
                
	    Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@oracle.cise.ufl.edu:1521:orcl",input.get(0), input.get(1)); 
	    Statement stmt = conn.createStatement ();
	    
	    Process p0= Runtime.getRuntime().exec("sqlplus " + input.get(0) + "@orcl/"+ input.get(1)+ " @BasicTables.sql");
	   p0.waitFor();

	   Process p2 = Runtime.getRuntime().exec("sqlldr " + input.get(0) + "/"+ input.get(1) + "@orcl control=Queries.ctl");
	    p2.waitFor();     

	    Process p3 = Runtime.getRuntime().exec("sqlldr " + input.get(0) + "/"+ input.get(1) + "@orcl control=Advertisers.ctl");
	    p3.waitFor();
        
	    Process p4 = Runtime.getRuntime().exec("sqlldr " + input.get(0) + "/"+ input.get(1) + "@orcl control=Keywords.ctl");
	    p4.waitFor();  

	    System.out.println("Done with loading .dat");

	    cstmt = conn.prepareCall("{call tokenize}");
	    cstmt.execute();
	    cstmt.close();  
         
	    System.out.println("Done with tokenize");


	    Process p1= Runtime.getRuntime().exec("sqlplus " + input.get(0) + "@orcl/"+ input.get(1)+ " @InformationTables.sql");
	    p1.waitFor();
         
	    System.out.println("Done with creating tables");

	    Process p5= Runtime.getRuntime().exec("sqlplus " + input.get(0) + "@orcl/"+ input.get(1)+ " @Procedures.sql");
 	    p5.waitFor();

	    System.out.println("Done with creating procedure");

 		 
 	    cstmt = conn.prepareCall("{call displayGreedyFirstPriceAll(?)}");		    cstmt.setInt(1,k.get(0));
 	    cstmt.execute();
 	    cstmt.close();

	    System.out.println("Done with greedyfirst");

 				 				
 	    cstmt = conn.prepareCall("{call displayBalancedFirstPriceAll(?)}"); 
 	    cstmt.setInt(1,k.get(1));
 	    cstmt.execute();
 	    cstmt.close();

	    System.out.println("Done with balance first");

	    cstmt = conn.prepareCall("{call displayPsiFirstPriceAll(?)}"); 
 	    cstmt.setInt(1,k.get(2));
 	    cstmt.execute();
 	    cstmt.close();

	    System.out.println("Done with psi first");

 	    cstmt = conn.prepareCall("{call displayGreedySecondPriceAll(?)}"); 
 	    cstmt.setInt(1,k.get(3));
 	    cstmt.execute();
 	    cstmt.close();

	    System.out.println("Done with greedy second");

 	    cstmt = conn.prepareCall("{call displayBalancedSecondPriceAll(?)}");	    cstmt.setInt(1,k.get(4));
 	    cstmt.execute();
 	    cstmt.close();

	    System.out.println("Done with  balance second");

 	    cstmt = conn.prepareCall("{call displayPsiSecondPriceAll(?)}"); 
 	    cstmt.setInt(1,k.get(5));
 	    cstmt.execute();
 	    cstmt.close();

	    System.out.println("Done with psi second");
		
 	    writeData(conn, "system.out.1", "GreedyFirstPriceResult");
	    writeData(conn, "system.out.2", "GreedySecondPriceResult");
 	    writeData(conn, "system.out.3", "BalanceFirstPriceResult");
 	    writeData(conn, "system.out.4", "BalanceSecondPriceResult");
	    writeData(conn, "system.out.5", "PsiFirstPriceResult");
 	    writeData(conn, "system.out.6", "PsiSecondPriceResult"); 
         
	    conn.close(); 
    }
    
    // method to write to txt
    public static 
    void writeData(Connection conn, String filename, String taskortablename) 
	throws IOException
    {
	String table = new String();
	table = taskortablename; 
	FileOutputStream fop = null;
	BufferedWriter writer = null;
	try
	{
	    fop=new FileOutputStream(filename,true); 
	    writer = new BufferedWriter(new OutputStreamWriter(fop));
	    
	    Statement select = conn.createStatement();
	    ResultSet result = select.executeQuery("select * from "+table+" order by qid, rank");
	    
	    ResultSetMetaData rsmd = result.getMetaData();
	    int columnCount = rsmd.getColumnCount();
	    while (result.next())
	    {
		StringBuilder row = new StringBuilder();
		for (int i = 1; i <= columnCount; i++)
		{
		    if (i%5 != 0) {
		    row.append(result.getObject(i) + ", ");
		    } else {
		    row.append(result.getObject(i));
		    }
		}
		writer.write(row.toString());
		writer.newLine();	
	    }
	}//try block 
	catch (Exception e){
	    e.printStackTrace();
	}
		
	writer.close();
    }
}

