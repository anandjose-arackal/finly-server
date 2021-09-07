import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class App {
    public static void main(String[] args) throws Exception {
        String message = "{\"chId\":1,\"custDetails\":{\"mobileNo\":\"8879397255\",\"customerTags\":[{\"name\":\"EMAIL\",\"value\":\"mk.chekuri@gmail.com\"},{\"name\":\"AADHAAR\",\"value\":\"499118665246\"},{\"name\":\"PAN\",\"value\":\"BXXCG7754K\"}]},\"agentDetails\":{\"agentId\":\"YB31YB41MOB521611569\",\"deviceTags\":[{\"name\":\"INITIATING_CHANNEL\",\"value\":\"INT\"},{\"name\":\"IP\",\"value\":\"124.170.23.24\"},{\"name\":\"MAC\",\"value\":\"01-23-45-67-89-ab\"}]},\"billDetails\":{\"billerId\":\"ASCE00000NATGK\",\"billerName\":\"Ascend Capital\",\"customerParams\":[{\"name\":\"Loan number\",\"value\":\"17000036\"}]}}"
        String secretKey = "2321bd46f297a35241efe1744df7898c";
        String base64EncryptedString;
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
        System.out.print(base64EncryptedString);
    }
}

