package com.id3.model.dto;

import lombok.Data;

@Data
public class UpdatePersonnelStatusRequest {
    private String email;
    private String status;
}
