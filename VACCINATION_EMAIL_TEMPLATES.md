# Email Template System for Vaccination Notifications

## Overview
The maternal health system now supports two distinct email templates for vaccination notifications:

1. **Child Vaccination Template** - For vaccinations given to children/babies
2. **Maternal Vaccination Template** - For vaccinations given to pregnant mothers

## How It Works

### Automatic Template Selection
The system automatically determines which template to use based on:

1. **Vaccination Type Detection**: Checks if the vaccination type is commonly given to pregnant mothers:
   - Tetanus (TT, Td, Tdap)
   - COVID-19 vaccines
   - Influenza (Flu, H1N1)
   - Pertussis (Whooping Cough)
   - Hepatitis B
   - MMR (Measles, Mumps, Rubella)

2. **Recipient Name Matching**: If the "child name" field matches the mother's name, it's treated as a maternal vaccination

### Email Template Differences

#### Child Vaccination Template
- **Header**: "Vaccination Record Updated" with child-focused messaging
- **Icon**: 💉 (syringe emoji)
- **Color Scheme**: Green tones (#4FC3A1)
- **Content**: Focus on child's immunization, includes child name prominently
- **Reminders**: Child-specific health tips and vaccination schedule

#### Maternal Vaccination Template
- **Header**: "Maternal Vaccination Updated" with pregnancy-focused messaging
- **Icon**: 🤰 (pregnant woman emoji)
- **Color Scheme**: Pink tones (#FF6B9D)
- **Content**: Focus on maternal and fetal health protection
- **Special Sections**: 
  - Pregnancy highlight box with "Protecting You and Your Baby" message
  - Maternal health reminders specific to pregnancy care
  - Emphasis on prenatal care importance

## Usage in Frontend

When adding vaccination records through the UI:

### For Child Vaccinations:
```dart
VaccinationRequest(
  motherNic: "123456789V",
  childName: "Baby John", // Child's actual name
  vaccinationType: "DPT", // Child vaccine
  // ... other fields
)
```

### For Maternal Vaccinations:
```dart
VaccinationRequest(
  motherNic: "123456789V",
  childName: "Mary Johnson", // Mother's name (same as registered name)
  vaccinationType: "Tetanus", // Maternal vaccine
  ageToGive: "28 weeks pregnancy", // Pregnancy stage instead of child age
  // ... other fields
)
```

## Benefits

1. **Contextual Messaging**: Mothers receive appropriate information based on whether the vaccination is for them or their child
2. **Better User Experience**: Clear distinction between child and maternal health communications
3. **Compliance**: Proper maternal health messaging for pregnancy-related vaccinations
4. **Professional Communication**: Specialized templates maintain medical communication standards

## Technical Implementation

- **Backend**: `VaccinationService.isMaternalVaccination()` method determines template selection
- **Email Service**: Two separate methods handle template generation
- **Automatic**: No frontend changes needed - system automatically selects correct template