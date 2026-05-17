package com.id3.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class UpdatePersonnelStatusRequest {
    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Pattern(regexp = "ACTIVE|INACTIVE|ON_LEAVE", message = "Status must be ACTIVE, INACTIVE, or ON_LEAVE")
    private String status;
}
