// package com.upi.merchanttoolkit.security;
package security;

import java.security.NoSuchAlgorithmException;
import javax.crypto.*;
import javax.crypto.spec.SecretKeySpec;


public class UPISecurity {
      private SecretKeySpec skeySpec;
      private Cipher cipher;

      public static void main(String[] args) {
        UPISecurity sec = new UPISecurity();
        String message = args[0];
        String key = args[1];
        try {
        String enc = sec.encrypt(message, key);
        System.out.println(enc);
      } catch (Exception e){
      }
        // System.out.println(enc);
      }

      /**
      * Constructor
      */
      public UPISecurity() {
            skeySpec = null;
            cipher = null;
      }

      /**
      * This method is used to init encryption
      *
       * @param key
      * @throws Exception
      */
      public void initEncrypt(String key) throws Exception {
            try {
                        skeySpec = new SecretKeySpec(UPISecurity.HexfromString(key), "AES");
                        cipher = Cipher.getInstance("AES");
                        cipher.init(1, skeySpec);
            } catch (NoSuchAlgorithmException nsae) {
                        throw new Exception("Invalid Java Version");
            } catch (NoSuchPaddingException nse) {
                        throw new Exception("Invalid Key");
            }
      }

      /**
      * This method is used to init decryption
      *
       * @param key
      * @throws Exception
      */
      public void initDecrypt(String key) throws Exception {
            try {
                        skeySpec = new SecretKeySpec(UPISecurity.HexfromString(key), "AES");
                        cipher = Cipher.getInstance("AES");
                        cipher.init(2, skeySpec);

            } catch (NoSuchAlgorithmException nsae) {
                        throw new Exception("Invalid Java Version");
            } catch (NoSuchPaddingException nse) {
                        throw new Exception("Invalid Key");
            }
      }

      /**
      * This method is used to return encrypted data.
      *
       * @param instr
      * @return String
      * @throws Exception
      */
      public String encrypt(String message,String enc_key) throws Exception {
            try {
                        initEncrypt(enc_key);

                        byte encstr[] = cipher.doFinal(message.getBytes());
                        return UPISecurity.HextoString(encstr);
            } catch (BadPaddingException nse) {
                        throw new Exception("Invalid input String");
            }
      }

      /**
      * This method is used to return decrypted data.
      *
       * @param instr
      * @return String
      * @throws Exception
      */
      public String decrypt(String message,String dec_key) throws Exception {
            try {

                        initDecrypt(dec_key);

                        byte encstr[] = cipher.doFinal(UPISecurity.HexfromString(message));
                        return new String(encstr);
            } catch (BadPaddingException nse) {
                        throw new Exception("Invalid input String");
            }
      }

      /**
            * Encode some data and return a String.
            */
            public final static String encode(byte[] d) {
                        if (d == null)
                            return null;
                        byte data[] = new byte[d.length + 2];
                        System.arraycopy(d, 0, data, 0, d.length);
                        byte dest[] = new byte[(data.length / 3) * 4];

                        // 3-byte to 4-byte conversion
                        for (int sidx = 0, didx = 0; sidx < d.length; sidx += 3, didx += 4) {
                                    dest[didx] = (byte) ((data[sidx] >>> 2) & 077);
                                    dest[didx + 1] = (byte) ((data[sidx + 1] >>> 4) & 017 | (data[sidx] << 4) & 077);
                                    dest[didx + 2] = (byte) ((data[sidx + 2] >>> 6) & 003 | (data[sidx + 1] << 2) & 077);
                                    dest[didx + 3] = (byte) (data[sidx + 2] & 077);
                        }

                        // 0-63 to ascii printable conversion
                        for (int idx = 0; idx < dest.length; idx++) {
                                    if (dest[idx] < 26)
                                                dest[idx] = (byte) (dest[idx] + 'A');
                                    else if (dest[idx] < 52)
                                                dest[idx] = (byte) (dest[idx] + 'a' - 26);
                                    else if (dest[idx] < 62)
                                                dest[idx] = (byte) (dest[idx] + '0' - 52);
                                    else if (dest[idx] < 63)
                                                dest[idx] = (byte) '+';
                                    else
                                                dest[idx] = (byte) '/';
                        }

                        // add padding
                        for (int idx = dest.length - 1; idx > (d.length * 4) / 3; idx--) {
                                    dest[idx] = (byte) '=';
                        }
                        return new String(dest);
            }

            /**
            * Encode a String using Base64 using the default platform encoding
            **/
            public final static String encode(String s) {
                        return encode(s.getBytes());
            }

            /**
            * Decode data and return bytes.
            */
            public final static byte[] decode(String str) {
                        if (str == null)
                                    return null;
                        byte data[] = str.getBytes();
                        return decode(data);
            }

            /**
            * Decode data and return bytes. Assumes that the data passed in is ASCII
            * text.
            */
            public final static byte[] decode(byte[] data) {
                        int tail = data.length;
                        while (data[tail - 1] == '=')
                                    tail--;
                        byte dest[] = new byte[tail - data.length / 4];

                        // ascii printable to 0-63 conversion
                        for (int idx = 0; idx < data.length; idx++) {
                                    if (data[idx] == '=')
                                                data[idx] = 0;
                                    else if (data[idx] == '/')
                                                data[idx] = 63;
                                    else if (data[idx] == '+')
                                                data[idx] = 62;
                                    else if (data[idx] >= '0' && data[idx] <= '9')
                                                data[idx] = (byte) (data[idx] - ('0' - 52));
                                    else if (data[idx] >= 'a' && data[idx] <= 'z')
                                                data[idx] = (byte) (data[idx] - ('a' - 26));
                                    else if (data[idx] >= 'A' && data[idx] <= 'Z')
                                                data[idx] = (byte) (data[idx] - 'A');
                        }

                        // 4-byte to 3-byte conversion
                        int sidx, didx;
                        for (sidx = 0, didx = 0; didx < dest.length - 2; sidx += 4, didx += 3) {
                                    dest[didx] = (byte) (((data[sidx] << 2) & 255) | ((data[sidx + 1] >>> 4) & 3));
                                    dest[didx + 1] = (byte) (((data[sidx + 1] << 4) & 255) | ((data[sidx + 2] >>> 2) & 017));
                                    dest[didx + 2] = (byte) (((data[sidx + 2] << 6) & 255) | (data[sidx + 3] & 077));
                        }
                        if (didx < dest.length) {
                                    dest[didx] = (byte) (((data[sidx] << 2) & 255) | ((data[sidx + 1] >>> 4) & 3));
                        }
                        if (++didx < dest.length) {
                                    dest[didx] = (byte) (((data[sidx + 1] << 4) & 255) | ((data[sidx + 2] >>> 2) & 017));
                        }
                        return dest;
            }

            /**
            * This method is used to convert string in to hex format
            *
             * @param s
            * @return byte[]
            */
            public static byte[] HexfromString(String s) {
                        int i = s.length();
                        byte abyte0[] = new byte[(i + 1) / 2];
                        int j = 0;
                        int k = 0;
                        if (i % 2 == 1)
                                    abyte0[k++] = (byte) HexfromDigit(s.charAt(j++));
                        while (j < i)
                                    abyte0[k++] = (byte) (HexfromDigit(s.charAt(j++)) << 4 | HexfromDigit(s.charAt(j++)));
                        return abyte0;
            }

            /**
            * This method is used to return Hex form Digit
            *
             * @param c
            * @return int
            */
            public static int HexfromDigit(char c) {
                        if (c >= '0' && c <= '9')
                                    return c - 48;
                        if (c >= 'A' && c <= 'F')
                                    return (c - 65) + 10;
                        if (c >= 'a' && c <= 'f')
                                    return (c - 97) + 10;
                        else
                                    throw new IllegalArgumentException("invalid hex digit: " + c);
            }

            /**
            * This method is used to return string as Hex
            *
             * @param buf
            * @return String
            */
            public static String asHex(byte buf[]) {
                        StringBuffer strbuf = new StringBuffer(buf.length * 2);
                        for (int i = 0; i < buf.length; i++) {
                                    if ((buf[i] & 0xff) < 16)
                                                strbuf.append("0");
                                    strbuf.append(Long.toString(buf[i] & 0xff, 16));
                        }

                        return strbuf.toString();
            }

            /**
            * This method is used to convert Hex to string
            *
             * @param abyte0
            * @param i
            * @param j
            * @return String
            */
            public static String HextoString(byte abyte0[], int i, int j) {
                        char ac[] = new char[j * 2];
                        int k = 0;
                        for (int l = i; l < i + j; l++) {
                                    byte byte0 = abyte0[l];
                                    ac[k++] = hexDigits[byte0 >>> 4 & 0xf];
                                    ac[k++] = hexDigits[byte0 & 0xf];
                        }
                        return new String(ac);
            }

            /**
            * This method is used to convert Hex to string
            *
             * @param abyte0
            * @return String
            */
            public static String HextoString(byte abyte0[]) {
                        return HextoString(abyte0, 0, abyte0.length);
            }

            private static final char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

}
