package tesseractOCR;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import org.apache.tika.exception.TikaException;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.parser.ParseContext;
import org.apache.tika.parser.ocr.TesseractOCRConfig;
//import org.apache.tika.parser.ocr.TesseractOCRParser;
import org.apache.tika.sax.BodyContentHandler;
import org.xml.sax.SAXException;

import magick.MagickException;

public class TessParser {
	
   public static void main(final String[] args) throws IOException,SAXException, TikaException, MagickException {
	  String inputfileName = "eng.arial.exp";
	  
	  for(int i=1;i<4;i++) {
		 inputfileName += i + ".tiff";
		 
		 BodyContentHandler handler = new BodyContentHandler();
		  Metadata metadata = new Metadata();
		  FileInputStream inputstream = new FileInputStream(new File(inputfileName));
		  ParseContext pcontext=new ParseContext();
		  TesseractOCRConfig config = new TesseractOCRConfig();
		  pcontext.set(TesseractOCRConfig.class, config);
		  TesseractOCRParser tOCR = new TesseractOCRParser();
		  tOCR.parse(inputstream, handler, metadata, pcontext);
		  
		  System.out.println("Contents of the document:" + handler.toString());
		  System.out.println("Metadata of the document:");
		  String[] metadataNames = metadata.names();
		  
		  for(String name : metadataNames) {
		     System.out.println(name + " : " + metadata.get(name));
		  }
		  inputfileName = "eng.arial.exp";
	  }
	   
      /*ImageInfo info = new ImageInfo(inputfileName); 
      MagickImage magick_converter = new MagickImage(info); 
      
      String outputfile = "img1_out.jpg"; 
      magick_converter.setFileName(outputfile); 
      //magick_converter = magick_converter.scaleImage(1000, 1000);
      magick_converter.enhanceImage();
      magick_converter.writeImage(info);
	  */     
      
   }
}