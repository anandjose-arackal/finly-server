import java.io.UnsupportedEncodingException;
import java.security.Key;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import sun.misc.BASE64Encoder;


public class GenericEncrypter {
    public static final String FIX_LENGTH_DATA = "NoPadding";
    public static final String VARIABLE_LENGTH_DATA = "PKCS5Padding";

    private Cipher cipher = null;
    private Key key = null;
    private String padding = null;
    private String algorithm = null;
    private String enctype = null;
    IvParameterSpec ivspec = null;

    public GenericEncrypter() {
        padding = FIX_LENGTH_DATA;
        algorithm = "DESEDE";
        enctype = "ECB";
    }

    public GenericEncrypter(String algo, String encryptionType, String paddingType, byte[] iv) {
        padding = paddingType;
        algorithm = algo;
        enctype = encryptionType;
        if (enctype.equals("CBC"))
        {
            // System.out.println("GenericEncrypter: iv: " + iv.length);
            ivspec = new IvParameterSpec(iv);
        }
    }

    public byte[] getKey() {
        byte[] bytes = key.getEncoded();
        return bytes;
    }

    public void setKey(String strKey, int keylength)
    {
        int length = strKey.length();
        int difference = length % keylength;
        if (difference != 0)
        {
            difference = keylength - difference;
        }
        byte[] paddedArray = new byte[length + difference];
        byte[] byteArray = null;
        try
        {
            byteArray = strKey.getBytes("UTF-8");
        }
        catch(UnsupportedEncodingException e)
        {
            e.printStackTrace();
            byteArray = null;
        }
        for(int i=0;i<(length + difference);i++)
        {
            if (i < length)
            {
                paddedArray[i] = byteArray[i];
            }
            else
                paddedArray[i] = 0x00;
        }
        setKey(paddedArray);
    }

    public byte[] padString(String encstr, int keylength)
    {
        int length = encstr.length();
        int difference = length % keylength;
        if (difference != 0)
        {
            difference = keylength - difference;
        }
        byte[] paddedArray = new byte[length + difference];
        byte[] byteArray = null;
        try
        {
            byteArray = encstr.getBytes("UTF-8");
        }
        catch(UnsupportedEncodingException e)
        {
            e.printStackTrace();
            byteArray = null;
        }
        for(int i=0;i<(length + difference);i++)
        {
            if (i < length)
            {
                paddedArray[i] = byteArray[i];
            }
            else
                paddedArray[i] = 0x00;
        }
        return paddedArray;
    }


    public void setKey(byte[] bytes) {
        // System.out.println("GenericEncrypter: setKey: " + bytes.length);
        key = new SecretKeySpec(bytes, algorithm);
    }

    //for 3DES
    public void generateKey() throws Exception {
        KeyGenerator keyGen = KeyGenerator.getInstance(algorithm);
        keyGen.init(168);
        key = keyGen.generateKey();
    }

    public String getPadding() {
        return padding;
    }

    public void setPadding(String padding) {
        this.padding = padding;
    }

    public byte[] encrypt(byte[] plainText) throws Exception {
        cipher = Cipher.getInstance(algorithm + "/" + enctype + "/" + padding);
        if (enctype.equals("ECB"))
            cipher.init (Cipher.ENCRYPT_MODE, key);
        else
            cipher.init (Cipher.ENCRYPT_MODE, key, ivspec);
        // System.out.println(plainText);
        byte[] encryptedText = cipher.doFinal(plainText);
        return encryptedText;
    }

    public byte[] decrypt(byte[] encryptedText) throws Exception {
        cipher = Cipher.getInstance(algorithm + "/" + enctype + "/" + padding);
        if (enctype.equals("ECB"))
            cipher.init (Cipher.DECRYPT_MODE, key);
        else
            cipher.init (Cipher.DECRYPT_MODE, key, ivspec);
        byte[] plainText = cipher.doFinal(encryptedText);
        return plainText;
    }

    public String encrypt(String plaintext, String outputformat)
    {
        String text = null;
        try
        {
            byte[] encryptedBytes = encrypt(plaintext.getBytes("UTF-8"));
            // System.out.println(encryptedBytes);
            if (outputformat.equals("HEX"))
            {
                StringBuffer sb = new StringBuffer();
                for(byte b : encryptedBytes) {
                    sb.append(String.format("%02x", b));
                }
                text = sb.toString();
            }
            else
            {
                return (new BASE64Encoder()).encode(encryptedBytes);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return null;
        }
        return text;
    }

    public String encrypt(byte[] plainText, String outputformat)
    {
        String text = null;
        try
        {
            byte[] encryptedBytes = encrypt(plainText);
            if (outputformat.equals("HEX"))
            {
                StringBuffer sb = new StringBuffer();
                for(byte b : encryptedBytes) {
                    sb.append(String.format("%02x", b));
                }
                text = sb.toString();
            }
            else
            {
                return (new BASE64Encoder()).encode(encryptedBytes);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return null;
        }
        return text;
    }

    public String decrypt(String encText, String inputformat, String outputformat)
    {
        try
        {
            byte[] encbytes = null;
            if (inputformat.equals("HEX"))
            {
                encbytes = hexStringToByteArray(encText);
            }
            else
            {
                encbytes = new sun.misc.BASE64Decoder().decodeBuffer(encText);
            }
            return decrypt(encbytes,outputformat);
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return null;
        }
    }

    public String decrypt(byte[] encText, String outputformat)
    {
        String text = null;
        try
        {
            byte[] decryptedBytes = decrypt(encText);
            if (outputformat.equals("HEX"))
            {
                StringBuffer sb = new StringBuffer();
                for(byte b : decryptedBytes) {
                    sb.append(String.format("%02x", b));
                }
                text = sb.toString();
            }
            else if (outputformat.equals("PLAINTEXT"))
            {
                return new String(decryptedBytes);
            }
            else
            {
                return (new BASE64Encoder()).encode(decryptedBytes);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return null;
        }
        return text;
    }

    public static byte[] hexStringToByteArray(String s)
    {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2)
        {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i + 1), 16));
        }
        return data;
    }


    public static void main(String args[]) {
        String iv = "42bb6d311df6dc6437cee2d3dd135d06";
        String key = "a2fb675a04082d5082354200b170555298fe7326a408e72f3ae5ff807327b8a7";
        String encryptParams = "";
        String output;
        if (args != null && args.length == 2) {
          encryptParams = args[0] + "," + args[1];
        }else{
          throw new IllegalArgumentException();
        }
        GenericEncrypter gen=new GenericEncrypter("AES", "CBC", "PKCS5Padding", GenericEncrypter.hexStringToByteArray(iv));
        try
            {
                gen.setKey(GenericEncrypter.hexStringToByteArray(key));
            } catch (Exception e)
            {
                e.printStackTrace();
            }

    //For encryption
        output = gen.encrypt(encryptParams, "HEX");

        System.out.printf(output);

    }

}



