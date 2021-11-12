import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class App {
    public static void main(String[] args) throws Exception {
        String secretKey = "083d0fb5ccec3b7b96ef2f1919f14d3c";
        try {
            String encoded_message = args[0];
            String base64EncryptedString;

            byte[] encVal = encoded_message.getBytes();
            String message = new String(Base64.getDecoder().decode(encVal), StandardCharsets.UTF_8);

            MessageDigest md = MessageDigest.getInstance("SHA-256"); 
            byte[] digestOfPassword = md.digest(secretKey.getBytes("UTF8"));
            byte[] keyBytes = Arrays.copyOf(digestOfPassword, 24);
            byte []iv = new byte[]{106,21,89,46,-4,95,75,-87,-109,76,-77,49,0,78,63,96};
            SecretKey key = new SecretKeySpec(keyBytes, "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
            IvParameterSpec ivParameterSpec = new IvParameterSpec(iv); 
            cipher.init(Cipher.ENCRYPT_MODE, key, ivParameterSpec); 
            byte[] plainTextBytes = message.getBytes("UTF8");
            byte[] buf = cipher.doFinal(plainTextBytes);
            String base64Bytes =  Base64.getEncoder().encodeToString(buf);
            base64EncryptedString = new String(base64Bytes);
            System.out.println(base64EncryptedString);

        } catch (Exception e){
            System.out.println("Exception occured while encrypting bbps " + e);
        }
    }
}