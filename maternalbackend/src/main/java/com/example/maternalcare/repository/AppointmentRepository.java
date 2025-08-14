package com.example.maternalcare.repository;

import com.example.maternalcare.model.Appointment;
import com.example.maternalcare.model.Appointment.AppointmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    
    List<Appointment> findByMotherNicOrderByAppointmentDateDesc(String motherNic);
    
    List<Appointment> findByMotherNicAndStatusOrderByAppointmentDateDesc(String motherNic, AppointmentStatus status);
    
    List<Appointment> findByProviderNameOrderByAppointmentDateAsc(String providerName);
    
    List<Appointment> findByAppointmentDateBetweenOrderByAppointmentDateAsc(LocalDateTime startDate, LocalDateTime endDate);
    
    @Query("SELECT a FROM Appointment a WHERE a.providerName = :providerName AND a.appointmentDate BETWEEN :startDate AND :endDate ORDER BY a.appointmentDate ASC")
    List<Appointment> findByProviderAndDateRange(@Param("providerName") String providerName, 
                                               @Param("startDate") LocalDateTime startDate, 
                                               @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT COUNT(a) FROM Appointment a WHERE a.providerName = :providerName AND a.appointmentDate = :appointmentDate AND a.timeSlot = :timeSlot AND a.status != 'CANCELLED'")
    Long countByProviderAndDateTimeSlot(@Param("providerName") String providerName, 
                                       @Param("appointmentDate") LocalDateTime appointmentDate, 
                                       @Param("timeSlot") String timeSlot);
    
    boolean existsByMotherNicAndAppointmentDateAndTimeSlotAndStatusNot(String motherNic, 
                                                                      LocalDateTime appointmentDate, 
                                                                      String timeSlot, 
                                                                      AppointmentStatus status);

    // Check if mother already has an appointment with a provider on the same date
    @Query("SELECT COUNT(a) > 0 FROM Appointment a WHERE a.motherNic = :motherNic AND a.providerName = :providerName AND DATE(a.appointmentDate) = DATE(:appointmentDate) AND a.status != 'CANCELLED'")
    boolean existsByMotherNicAndProviderAndDateAndStatusNot(@Param("motherNic") String motherNic, 
                                                            @Param("providerName") String providerName,
                                                            @Param("appointmentDate") LocalDateTime appointmentDate);

    // Find appointments by provider ID and date range
    List<Appointment> findByProviderIdAndAppointmentDateBetweenOrderByAppointmentDateAsc(String providerId, 
                                                                                        LocalDateTime startDate, 
                                                                                        LocalDateTime endDate);

    // Find appointments by appointment type and date range
    List<Appointment> findByAppointmentTypeAndAppointmentDateBetweenOrderByAppointmentDateAsc(String appointmentType, 
                                                                                             LocalDateTime startDate, 
                                                                                             LocalDateTime endDate);

    // Find appointments by provider ID, NIC (partial match) and date range
    List<Appointment> findByProviderIdAndMotherNicContainingAndAppointmentDateBetweenOrderByAppointmentDateAsc(String providerId, 
                                                                                                               String motherNic, 
                                                                                                               LocalDateTime startDate, 
                                                                                                               LocalDateTime endDate);

    // Find upcoming appointments by appointment type (after a specific date)
    List<Appointment> findByAppointmentTypeAndAppointmentDateAfterOrderByAppointmentDateAsc(String appointmentType, 
                                                                                           LocalDateTime afterDate);

    // Find upcoming appointments by provider ID (after a specific date)
    List<Appointment> findByProviderIdAndAppointmentDateAfterOrderByAppointmentDateAsc(String providerId, 
                                                                                      LocalDateTime afterDate);
    
    // Count appointments by provider ID and date range
    Long countByProviderIdAndAppointmentDateBetween(String providerId, 
                                                   LocalDateTime startDate, 
                                                   LocalDateTime endDate);
}
