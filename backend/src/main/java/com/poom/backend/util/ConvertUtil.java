package com.poom.backend.util;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;

public class ConvertUtil {

  // Double -> uint
  public static BigInteger etherToWei(Double amount){
    return new BigDecimal(amount).multiply( new BigDecimal("1000000000000000000")).toBigInteger();
  }

  // uint -> Double
  public static Double weiToEther(BigInteger amount) {
    BigDecimal divisor = new BigDecimal("1000000000000000000"); // 10^18
    return new BigDecimal(amount).divide(divisor).doubleValue();
  }
  // LocalDateTime -> uint
  public static BigInteger dateTimeToBigInteger(LocalDateTime localDateTime){
    Instant instant = localDateTime.atZone(ZoneId.of("Asia/Seoul")).toInstant();
    long unixEpoch = instant.getEpochSecond();
    return BigInteger.valueOf(unixEpoch);
  }

  // uint -> LocalDateTime
  public static LocalDateTime bigIntegerToDateTime(BigInteger bigInteger){
    Instant instant = Instant.ofEpochSecond(bigInteger.longValue());
    LocalDateTime utcLocalDateTime = instant.atZone(ZoneId.of("Asia/Seoul")).toLocalDateTime();;
    return utcLocalDateTime;
  }

}
