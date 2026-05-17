package com.id3.service;

import com.id3.config.JwtService;
import com.id3.model.dto.AuthenticationRequest;
import com.id3.model.dto.AuthenticationResponse;
import com.id3.model.dto.RegisterRequest;
import com.id3.model.entity.PersonnelInfo;
import com.id3.model.entity.Role;
import com.id3.model.entity.Status;
import com.id3.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class AuthenticationService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        var user = userRepository.findByEmail(request.getEmail());
        var jwtToken = jwtService.generateToken(user);
        return AuthenticationResponse.builder()
                .token(jwtToken)
                .userId(user.getPersonnelId())
                .role(String.valueOf(user.getRole()))
                .build();
    }

    public AuthenticationResponse register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()) != null) {
            throw new IllegalArgumentException("Email already registered: " + request.getEmail());
        }
        var user = PersonnelInfo.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(Role.EMPLOYEE)
                .status(Status.ACTIVE)
                .departmentName(request.getDepartmentName())
                .position(request.getPosition())
                .build();
        userRepository.save(user);
        var jwtToken = jwtService.generateToken(user);
        return AuthenticationResponse.builder()
                .token(jwtToken)
                .userId(user.getPersonnelId())
                .role(String.valueOf(user.getRole()))
                .build();
    }
}
