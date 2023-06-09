package com.poom.backend.api.dto.fundraiser;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class FundraiserDto {

    private Long fundraiserId;
    private String dogName;
    private int dogGender;
    private String mainImgUrl;
    private String nftImgUrl;
    private String shelterName;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yy.MM.dd", timezone = "Asia/Seoul")
    private LocalDate endDate;
    private Double currentAmount;
    private Double targetAmount;


}
