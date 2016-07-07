import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collection;

import org.apache.commons.io.FileUtils;
import org.apache.tika.exception.TikaException;
import org.apache.tika.io.TemporaryResources;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.parser.ParseContext;
import org.apache.tika.parser.jpeg.JpegParser;
import org.apache.tika.sax.BodyContentHandler;
import org.xml.sax.SAXException;

public class LabelImages {
	
	public static void main(String[] args) throws IOException {
		TemporaryResources tmp = new TemporaryResources();
		BufferedReader reader = null;
		BufferedWriter bw = null;
		File tmpFile = null;
	    String line = null;
		
		try {
			tmpFile = tmp.createTemporaryFile();
			bw = new BufferedWriter(new FileWriter(tmpFile.getAbsolutePath(), true));
			File file = new File("/Users/zaranaparekh1/Documents/final_training_data");       
			Collection<File> files = FileUtils.listFiles(file, null, true);     
			for(File file2 : files){
			    // System.out.println(file2.getName());
			    bw.write(file2.getAbsolutePath());
			    bw.newLine();
			    bw.flush();
			} 
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (bw != null) try {
			    bw.close();
			 } catch (IOException ioe) {
				ioe.printStackTrace();
			 }
		}

	    try {
	    	BodyContentHandler handler = new BodyContentHandler();
    		Metadata metadata = new Metadata();
    		ParseContext pcontext = new ParseContext();
    		FileInputStream inputstream;
    		reader = new BufferedReader(new FileReader (tmpFile));
    		
	        while((line = reader.readLine()) != null) {
	    		try {
	    			if(line.endsWith(".jpg")) {
	    				inputstream = new FileInputStream(new File(line));
		    			JpegParser  JpegParser = new JpegParser();
						JpegParser.parse(inputstream, handler, metadata, pcontext);
						System.out.println(line + "\n Contents of the document:" + handler.toString());
/*		    		      
						System.out.println("Metadata of the document:");
						String[] metadataNames = metadata.names();

						for(String name : metadataNames) { 		        
						 System.out.println(name + ": " + metadata.get(name));
						}
*/
	    			}
	    		} catch (FileNotFoundException e) {
	    			e.printStackTrace();
	    		} catch (IOException e) {
	    			e.printStackTrace();
	    		} catch (SAXException e) {
	    			e.printStackTrace();
	    		} catch (TikaException e) {
	    			e.printStackTrace();
	    		}
	        }
	    } catch (IOException e) {
			e.printStackTrace();
		} finally {
	        reader.close();
	    }
	}
}
