package com.id3.controller;

import com.id3.model.authPage.AuthResponse;
import com.id3.model.authPage.LoginForm;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;

@Controller
@Slf4j
@RequestMapping("/ui/auth")
@RequiredArgsConstructor
public class AuthController {
    private final RestTemplate restTemplate;

    @Value("${gateway.url}")
    private String gatewayUrl;


    @GetMapping
    public String getAuthPage(Model model){
        model.addAttribute("loginForm", new LoginForm());
        return "auth";
    }

    @PostMapping("/login")
    public String login(@ModelAttribute LoginForm loginForm, Model model,  HttpServletResponse response) {
        String url = gatewayUrl+"/auth/authenticate";

        HttpEntity<LoginForm> request = new HttpEntity<>(loginForm);
        ResponseEntity<AuthResponse> responseEntity = restTemplate.exchange(url, HttpMethod.POST, request, AuthResponse.class);

        if (responseEntity.getStatusCode().is2xxSuccessful()) {
            AuthResponse authResponse = responseEntity.getBody();
            assert authResponse != null;
            String token = authResponse.getToken();
            int userId = authResponse.getUserId();


            log.info("email : " + loginForm.getEmail());

            Cookie cookie = new Cookie("token", token);
            cookie.setHttpOnly(true);   // prevents JavaScript access (XSS mitigation)
            cookie.setMaxAge(86400);    // 24 hours, matching JWT expiry
            cookie.setPath("/");
            response.addCookie(cookie);

            // Token stored in HttpOnly cookie — do NOT expose in URL (prevents token leakage via logs/history)
            String role = authResponse.getRole();
            String redirectUrl;

            if ("EMPLOYEE".equalsIgnoreCase(role)) {
                redirectUrl = "/ui/employee/" + userId;
            } else if ("ADMIN".equalsIgnoreCase(role)) {
                redirectUrl = "/ui/admin/" + userId;
            } else {
                redirectUrl = "/ui/hr/" + userId;
            }

            return "redirect:" + redirectUrl;
        } else {
            // Başarısız yanıt durumunda hata mesajı ekleyin
            model.addAttribute("error", "Invalid credentials or server error");
            return "auth";
        }
    }
}
