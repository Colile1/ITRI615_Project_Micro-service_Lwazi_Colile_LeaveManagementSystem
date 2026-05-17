package com.id3.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CreatePersonnelRequest implements IDto {

    @NotBlank(message = "First name is required")
    @Size(max = 50)
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Size(max = 50)
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 100)
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be 8-100 characters")
    private String password;

    @NotBlank(message = "Role is required")
    @Pattern(regexp = "ADMIN|HR|EMPLOYEE", message = "Role must be ADMIN, HR, or EMPLOYEE")
    private String role;

    private String managerMailAddr;

    @NotBlank(message = "Department name is required")
    @Size(max = 50)
    private String departmentName;

    @NotBlank(message = "Position is required")
    @Size(max = 50)
    private String position;

}
