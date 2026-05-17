package com.id3.repository;

import com.id3.model.entity.PersonnelInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IPersonnelInfoRepository extends JpaRepository<PersonnelInfo, Integer> {
    Optional<PersonnelInfo> findByEmail(String email);
}
