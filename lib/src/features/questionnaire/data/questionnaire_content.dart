import 'package:pcosense/src/features/questionnaire/data/questionnaire_constants.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_option.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_question.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_section.dart';

class QuestionnaireContent {
  static const disclaimer =
      'This tool is for screening and educational purposes only and is not a substitute for professional medical advice.';

  static List<QuestionnaireSection> buildSections() {
    return <QuestionnaireSection>[
      QuestionnaireSection(
        id: 'basic_profile',
        title: 'Basic profile',
        subtitle: 'A few basics help us tailor the screening language.',
        supportingText: 'Height, weight, and region are optional and used only for added context.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.ageGroup,
            title: 'Age group',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.under18, label: 'Under 18'),
              QuestionnaireOption(id: QuestionnaireValues.age18To24, label: '18-24'),
              QuestionnaireOption(id: QuestionnaireValues.age25To34, label: '25-34'),
              QuestionnaireOption(id: QuestionnaireValues.age35To44, label: '35-44'),
              QuestionnaireOption(id: QuestionnaireValues.age45Plus, label: '45+'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.heightCm,
            title: 'Height (optional)',
            inputType: QuestionnaireInputType.number,
            placeholder: 'e.g. 165',
            unitLabel: 'cm',
            helperText: 'Optional. If height and weight are added, we can estimate BMI for context.',
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.weightKg,
            title: 'Weight (optional)',
            inputType: QuestionnaireInputType.number,
            placeholder: 'e.g. 68',
            unitLabel: 'kg',
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.region,
            title: 'Country or region (optional)',
            inputType: QuestionnaireInputType.dropdown,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.northAmerica, label: 'North America'),
              QuestionnaireOption(id: QuestionnaireValues.latinAmerica, label: 'Latin America'),
              QuestionnaireOption(id: QuestionnaireValues.europe, label: 'Europe'),
              QuestionnaireOption(id: QuestionnaireValues.mena, label: 'Middle East and North Africa'),
              QuestionnaireOption(id: QuestionnaireValues.subSaharanAfrica, label: 'Sub-Saharan Africa'),
              QuestionnaireOption(id: QuestionnaireValues.southAsia, label: 'South Asia'),
              QuestionnaireOption(id: QuestionnaireValues.eastAsia, label: 'East Asia'),
              QuestionnaireOption(id: QuestionnaireValues.southeastAsia, label: 'Southeast Asia'),
              QuestionnaireOption(id: QuestionnaireValues.oceania, label: 'Oceania'),
              QuestionnaireOption(id: QuestionnaireValues.preferNot, label: 'Prefer not to answer'),
            ],
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'menstrual_pattern',
        title: 'Menstrual pattern',
        subtitle: 'Cycle timing is one of the main PCOS screening domains.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.periodRegularity,
            title: 'Are your periods regular?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.regular, label: 'Regular'),
              QuestionnaireOption(id: QuestionnaireValues.slightlyIrregular, label: 'Slightly irregular'),
              QuestionnaireOption(id: QuestionnaireValues.veryIrregular, label: 'Very irregular'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.cycleLength,
            title: 'Average cycle length',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.cycleLessThan21, label: '<21 days'),
              QuestionnaireOption(id: QuestionnaireValues.cycle21To35, label: '21-35 days'),
              QuestionnaireOption(id: QuestionnaireValues.cycleOver35, label: '>35 days'),
              QuestionnaireOption(id: QuestionnaireValues.cycleVaries, label: 'Varies widely'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.missedPeriods,
            title: 'Have you missed periods for 3 months or more?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'menstrual_context',
        title: 'Menstrual background',
        subtitle: 'These details help place your cycle history in context.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.menarcheAge,
            title: 'Age at first period',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.menarcheUnder12, label: 'Under 12'),
              QuestionnaireOption(id: QuestionnaireValues.menarche12To14, label: '12-14'),
              QuestionnaireOption(id: QuestionnaireValues.menarche15To16, label: '15-16'),
              QuestionnaireOption(id: QuestionnaireValues.menarche17Plus, label: '17+'),
              QuestionnaireOption(id: QuestionnaireValues.preferNot, label: 'Prefer not to answer'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.hormonalContraception,
            title: 'Do you currently use hormonal contraception?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
            ],
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'hyperandrogenism',
        title: 'Skin and hair changes',
        subtitle: 'These are common signs clinicians review when they think about androgen-related symptoms.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.excessHair,
            title: 'Do you have excess facial or body hair?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            isSensitive: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.preferNot, label: 'Prefer not to answer'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.excessHairSeverity,
            title: 'If yes, how severe is it?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            isSensitive: true,
            visibility: _showHairSeverity,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.mild, label: 'Mild'),
              QuestionnaireOption(id: QuestionnaireValues.moderate, label: 'Moderate'),
              QuestionnaireOption(id: QuestionnaireValues.severe, label: 'Severe'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.adultAcne,
            title: 'Do you have persistent acne as an adult?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.scalpHairLoss,
            title: 'Do you have scalp hair thinning or hair loss?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.oilySkin,
            title: 'Do you notice oily skin?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'metabolic_context',
        title: 'Metabolic and lifestyle context',
        subtitle: 'These answers add context but do not determine the result on their own.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.activityLevel,
            title: 'Current activity level',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.low, label: 'Low'),
              QuestionnaireOption(id: QuestionnaireValues.moderate, label: 'Moderate'),
              QuestionnaireOption(id: QuestionnaireValues.high, label: 'High'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.unexplainedWeightGain,
            title: 'Do you experience recent unexplained weight gain?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.difficultWeightLoss,
            title: 'Do you have difficulty losing weight?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'wellbeing_context',
        title: 'Family and wellbeing',
        subtitle: 'These questions can help with follow-up recommendations.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.familyHistory,
            title: 'Family history of PCOS, diabetes, or thyroid disorder?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            isSensitive: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
              QuestionnaireOption(id: QuestionnaireValues.preferNot, label: 'Prefer not to answer'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.sleepFatigue,
            title: 'Sleep issues or fatigue?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.stressLevel,
            title: 'Stress level',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.low, label: 'Low'),
              QuestionnaireOption(id: QuestionnaireValues.moderate, label: 'Moderate'),
              QuestionnaireOption(id: QuestionnaireValues.high, label: 'High'),
            ],
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'clinical_context',
        title: 'Optional clinical context',
        subtitle: 'You can skip this section if you have not had any testing yet.',
        supportingText: 'If you already have imaging or hormone test information, it can make the screening more useful.',
        isOptional: true,
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.ovarianUltrasound,
            title: 'Have you ever had an ultrasound scan of the ovaries?',
            inputType: QuestionnaireInputType.choice,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.polycysticAppearance,
            title: 'If yes, was polycystic ovary appearance mentioned?',
            inputType: QuestionnaireInputType.choice,
            visibility: _showUltrasoundResult,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.hormoneTests,
            title: 'Have you ever had hormone tests such as testosterone, LH, FSH, prolactin, or TSH?',
            inputType: QuestionnaireInputType.choice,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.notSure, label: 'Not sure'),
            ],
          ),
        ],
      ),
      QuestionnaireSection(
        id: 'safety',
        title: 'Safety check',
        subtitle: 'A couple of questions before we finish.',
        supportingText: 'Urgent symptoms need clinical care right away and will stop the screening result flow.',
        questions: <QuestionnaireQuestion>[
          QuestionnaireQuestion(
            id: QuestionnaireIds.pregnancyPostpartum,
            title: 'Are you pregnant, breastfeeding, or recently postpartum?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: const <QuestionnaireOption>[
              QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
              QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
              QuestionnaireOption(id: QuestionnaireValues.preferNot, label: 'Prefer not to answer'),
            ],
          ),
          QuestionnaireQuestion(
            id: QuestionnaireIds.urgentSymptoms,
            title: 'Are you experiencing severe pelvic pain, sudden heavy bleeding, or other urgent symptoms?',
            inputType: QuestionnaireInputType.choice,
            isRequired: true,
            options: _yesNoOptions(),
          ),
        ],
      ),
    ];
  }

  static List<QuestionnaireOption> _yesNoOptions() {
    return const <QuestionnaireOption>[
      QuestionnaireOption(id: QuestionnaireValues.yes, label: 'Yes'),
      QuestionnaireOption(id: QuestionnaireValues.no, label: 'No'),
    ];
  }

  static bool _showHairSeverity(Map<String, QuestionnaireAnswer> answers) {
    return answers[QuestionnaireIds.excessHair]?.value == QuestionnaireValues.yes;
  }

  static bool _showUltrasoundResult(Map<String, QuestionnaireAnswer> answers) {
    return answers[QuestionnaireIds.ovarianUltrasound]?.value == QuestionnaireValues.yes;
  }
}
