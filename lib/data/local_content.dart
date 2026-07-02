// lib/data/local_content.dart
import '../models/models.dart';

class LocalContent {
  static List<Unit> get units => [
        _unit1(),
        _unit2(),
        _unit3(),
        _unit4(),
        _unit5(),
        _unit6(),
      ];

  static Unit _unit1() {
    return Unit(
      id: 'unit1',
      number: 1,
      title: 'Historical Background',
      description: 'The Indian Constitution is the result of a long historical development.',
      color: '#6B9080',
      topics: [
        Topic(
          id: 'u1_t0', unitId: 'unit1',
          title: 'HISTORICAL BACKGROUND OF INDIAN CONSTITUTION',
          content: 'The Indian Constitution is the result of a long historical development. It did not come into existence suddenly. Several Acts passed by the British Parliament gradually shaped the constitutional system of India. These Acts introduced central government, judiciary, federalism, legislative bodies and responsible government. Each Act contributed to the making of the present Constitution.',
          keyPoints: [
            'Example: The federal system in India came from Government of India Act 1935.',
            'Illustration: British Acts → Reforms → Constitution 1950',
          ],
        ),
        Topic(
          id: 'u1_t1', unitId: 'unit1',
          title: 'REGULATING ACT, 1773',
          content: 'The Regulating Act of 1773 was the first step taken by the British Parliament to control the administration of the East India Company. Corruption and mismanagement were widespread, and the British Government felt the need to regulate the Company’s functioning. The Act created the office of Governor-General of Bengal and vested executive power in him. Warren Hastings became the first Governor-General. The presidencies of Bombay and Madras were brought under the control of Bengal. The Act also established the Supreme Court at Calcutta in 1774.',
          keyPoints: [
            'Example: Before 1773, Madras and Bombay acted independently. After this Act, they came under Bengal control.',
            'Illustration: Madras/Bombay/Calcutta → Governor General (Bengal). Centralization started.',
          ],
        ),
        Topic(
          id: 'u1_t2', unitId: 'unit1',
          title: 'PITT’S INDIA ACT, 1784',
          content: 'The Pitt’s India Act of 1784 was passed to remove the defects of the Regulating Act. This Act introduced a system of dual control. The political affairs of India were placed under a Board of Control appointed by the British Government, while the commercial affairs remained under the Court of Directors of the East India Company.',
          keyPoints: [
            'Example: British Government controlled policy while Company handled administration.',
            'Illustration: Board of Control (Political) & Court of Directors (Commercial).',
          ],
        ),
        Topic(
          id: 'u1_t3', unitId: 'unit1',
          title: 'CHARTER ACT, 1813',
          content: 'The Charter Act of 1813 renewed the charter of the East India Company but ended its monopoly over Indian trade except tea and trade with China. The Act permitted Christian missionaries to enter India and promote education. It also allocated one lakh rupees annually for education.',
          keyPoints: [
            'Example: Missionary schools started in India.',
            'Illustration: Trade monopoly ended → British traders entered India → Economic change.',
          ],
        ),
        Topic(
          id: 'u1_t4', unitId: 'unit1',
          title: 'CHARTER ACT, 1833',
          content: 'The Charter Act of 1833 centralized administration in India. It made the Governor-General of Bengal the Governor-General of India. Lord William Bentinck became the first Governor-General of India. Legislative power was centralized, and the presidencies lost legislative authority. The East India Company ceased to be a commercial body and became purely administrative.',
          keyPoints: [
            'Example: India became one administrative unit.',
            'Illustration: Bombay/Madras/Bengal → Governor General of India. Central legislature created.',
          ],
        ),
        Topic(
          id: 'u1_t5', unitId: 'unit1',
          title: 'CHARTER ACT, 1853',
          content: 'The Charter Act of 1853 introduced significant administrative reforms. It separated legislative and executive functions of the Governor-General’s Council. Additional members were added to the legislative council. The Act introduced open competition for civil services.',
          keyPoints: [
            'Example: Civil services examination started.',
            'Illustration: Before (Nomination) → After (Competitive exam).',
          ],
        ),
        Topic(
          id: 'u1_t6', unitId: 'unit1',
          title: 'GOVERNMENT OF INDIA ACT, 1858',
          content: 'The Government of India Act, 1858 transferred power from East India Company to British Crown after the Revolt of 1857. The office of Secretary of State for India was created. The Governor-General became Viceroy representing the Crown. Lord Canning became first Viceroy.',
          keyPoints: [
            'Example: Queen Victoria ruled India after 1858.',
            'Illustration: Before (Company rule) → After (Crown rule).',
          ],
        ),
        Topic(
          id: 'u1_t7', unitId: 'unit1',
          title: 'INDIAN COUNCILS ACT, 1861',
          content: 'The Indian Councils Act of 1861 introduced legislative decentralization. It expanded legislative councils and allowed nomination of Indians. Portfolio system introduced administrative efficiency.',
          keyPoints: [
            'Example: Indians nominated in legislative council.',
            'Illustration: British officials + Indian members = Council.',
          ],
        ),
        Topic(
          id: 'u1_t8', unitId: 'unit1',
          title: 'INDIAN COUNCILS ACT, 1892',
          content: 'The Indian Councils Act of 1892 introduced indirect election. Members were recommended by local bodies. Budget discussion allowed and questions asked.',
          keyPoints: [
            'Example: Members discussed government expenditure.',
            'Illustration: Local bodies → nominate members → council.',
          ],
        ),
        Topic(
          id: 'u1_t9', unitId: 'unit1',
          title: 'INDIAN COUNCILS ACT, 1909',
          content: 'The Indian Councils Act 1909 introduced separate electorates for Muslims. Legislative councils expanded. Indians got limited representation.',
          keyPoints: [
            'Example: Muslims elected Muslim representatives.',
            'Illustration: Separate electorate → communal representation.',
          ],
        ),
        Topic(
          id: 'u1_t10', unitId: 'unit1',
          title: 'GOVERNMENT OF INDIA ACT, 1919',
          content: 'The Government of India Act 1919 introduced diarchy in provinces. Subjects divided into reserved and transferred. Indians handled transferred subjects.',
          keyPoints: [
            'Example: Education handled by Indian ministers.',
            'Illustration: Reserved (British) / Transferred (Indians).',
          ],
        ),
        Topic(
          id: 'u1_t11', unitId: 'unit1',
          title: 'GOVERNMENT OF INDIA ACT, 1935',
          content: 'The Government of India Act 1935 introduced federal structure. Provincial autonomy granted. Three lists introduced. Federal Court established.',
          keyPoints: [
            'Example: Union list (Defence), State list (Police), Concurrent list (Education).',
            'Illustration: Centre + States → Federal system.',
          ],
        ),
        Topic(
          id: 'u1_t12', unitId: 'unit1',
          title: 'INDIAN INDEPENDENCE ACT, 1947',
          content: 'The Indian Independence Act 1947 ended British rule and created India and Pakistan. Legislative power given to Constituent Assembly.',
          keyPoints: [
            'Example: India became independent.',
            'Illustration: British rule ended → Sovereign India.',
          ],
        ),
        Topic(
          id: 'u1_t13', unitId: 'unit1',
          title: 'CONSTITUENT ASSEMBLY',
          content: 'The Constituent Assembly framed the Constitution. Rajendra Prasad presided and B. R. Ambedkar headed drafting committee. The Constitution was adopted on 26 November 1949 and came into force on 26 January 1950.',
          keyPoints: [
            'Example: Fundamental Rights drafted.',
            'Illustration: Debates → Draft → Constitution.',
          ],
        ),
      ],
      caseLaws: [
        CaseLaw(
          id: 'cl1_1', unitId: 'unit1',
          name: 'Nand Kumar Case',
          year: '1774',
          court: 'Supreme Court at Calcutta',
          facts: 'The Supreme Court tried Maharaja Nand Kumar for forgery and sentenced him to death.',
          held: 'Sentenced to death for forgery.',
          significance: 'Created conflict between Governor-General and Supreme Court, showing defects of Regulating Act.',
        ),
      ],
    );
  }

  static Unit _unit2() {
    return Unit(
      id: 'unit2', number: 2,
      title: 'Making of Constitution',
      description: 'Framing, Sources and Salient Features of the Indian Constitution.',
      color: '#BC6C25',
      topics: [
        Topic(
          id: 'u2_t1', unitId: 'unit2',
          title: 'MAKING OF CONSTITUTION',
          content: 'The Constitution was framed by the Constituent Assembly. It reflects the historical experiences, aspirations and ideals of democracy. The Assembly examined various constitutions and adopted suitable provisions. It is both original and borrowed.',
          keyPoints: [
            'Example: Guarantees equality before law.',
            'Illustration: People → Constituent Assembly → Constitution → Government',
          ],
        ),
        Topic(
          id: 'u2_t2', unitId: 'unit2',
          title: 'CONSTITUENT ASSEMBLY',
          content: 'Formed under Cabinet Mission Plan 1946. First meeting 9 Dec 1946. Dr. Rajendra Prasad was permanent chairman. Adopted on 26 Nov 1949.',
          keyPoints: [
            'Example: Fundamental Rights Committee prepared the list of rights.',
            'Illustration: Assembly → Committees → Draft → Debate → Constitution',
          ],
        ),
        Topic(
          id: 'u2_t3', unitId: 'unit2',
          title: 'DRAFTING COMMITTEE',
          content: 'Appointed 29 Aug 1947. Headed by B. R. Ambedkar. Prepared the draft based on committee reports. Article 32 was called the "heart and soul" by Dr. Ambedkar.',
          keyPoints: [
            'Illustration: Reports → Drafting Committee → Draft Constitution',
          ],
        ),
        Topic(
          id: 'u2_t4', unitId: 'unit2',
          title: 'SOURCES OF CONSTITUTION',
          content: 'UK (Parliamentary system), USA (Fundamental Rights), Ireland (DPSP), Canada (Federal system), Australia (Concurrent list), Germany (Emergency), USSR (Duties), South Africa (Amendment).',
          keyPoints: [
            'Illustration: UK + USA + Ireland + Canada → Indian Constitution',
          ],
        ),
        Topic(
          id: 'u2_t5', unitId: 'unit2',
          title: 'SALIENT FEATURES',
          content: 'Lengthiest written Constitution, Federal system with strong centre, Parliamentary form, Fundamental Rights, DPSP, Independent Judiciary, Secular State, Universal Adult Franchise, Single Citizenship.',
          keyPoints: [
            'Example: All citizens above 18 have voting rights.',
            'Illustration: Federal + Parliamentary + Rights + Duties = Indian Constitution',
          ],
        ),
        Topic(
          id: 'u2_t6', unitId: 'unit2',
          title: 'FEDERAL SYSTEM WITH UNITARY BIAS',
          content: 'Powers divided between centre and states, but centre is stronger. During emergency, centre controls states. Governors appointed by centre. Quasi-federal nature.',
          keyPoints: [
            'Case Law: State of West Bengal v Union of India (Quasi-federal).',
          ],
        ),
        Topic(
          id: 'u2_t7', unitId: 'unit2',
          title: 'PREAMBLE',
          content: 'Introduces the Constitution. Declares India Sovereign, Socialist, Secular, Democratic Republic. Ensures Justice, Liberty, Equality, Fraternity.',
          keyPoints: [
            'Case Law: Kesavananda Bharati (Preamble is part of Constitution).',
            'Case Law: Berubari Union (Preamble initially held not part).',
          ],
        ),
      ],
      caseLaws: [
        CaseLaw(id: 'cl2_1', unitId: 'unit2', name: 'Berubari Union Case', year: '1960', court: 'Supreme Court', facts: 'Cession of territory.', held: 'Preamble not part.', significance: 'Lower status of Preamble.'),
        CaseLaw(id: 'cl2_2', unitId: 'unit2', name: 'Kesavananda Bharati v State of Kerala', year: '1973', court: 'Supreme Court', facts: 'Land reform laws.', held: 'Preamble is part, Basic Structure cannot be amended.', significance: 'Most important case.'),
      ],
    );
  }

  static Unit _unit3() {
    return Unit(
      id: 'unit3', number: 3,
      title: 'Union and Citizenship',
      description: 'Article 1 to 11, reorganization of states and citizenship laws.',
      color: '#606C38',
      topics: [
        Topic(
          id: 'u3_t1', unitId: 'unit3',
          title: 'UNION OF INDIA (ARTICLE 1)',
          content: 'India (Bharat) is a Union of States. States cannot secede. Territory includes states, UTs and acquired areas.',
          keyPoints: [
            'Example: Tamil Nadu cannot separate from India.',
            'Illustration: India → Indestructible Union of destructible States.',
          ],
        ),
        Topic(
          id: 'u3_t2', unitId: 'unit3',
          title: 'STATE REORGANIZATION (ART 2-4)',
          content: 'Art 2: Admission of new states. Art 3: Formation of new states, changing names/boundaries. Art 4: Laws under 2 & 3 are not constitutional amendments (simple majority).',
          keyPoints: [
            'Example: Telangana (2014), Sikkim (1975).',
            'Illustration: State division → Parliament → New state',
          ],
        ),
        Topic(
          id: 'u3_t3', unitId: 'unit3',
          title: 'CITIZENSHIP (ART 5-11)',
          content: 'Part II. Art 5: Commencement. Art 6: Migrants from Pakistan. Art 7: Migrants to Pakistan. Art 8: Indians abroad. Art 9: Foreign citizenship = loss of Indian. Art 11: Parliament to regulate.',
          keyPoints: [
            'Example: Indian becoming US citizen loses Indian status.',
            'Illustration: Birth / Descent / Registration / Naturalization',
          ],
        ),
        Topic(
          id: 'u3_t4', unitId: 'unit3',
          title: 'SINGLE CITIZENSHIP',
          content: 'India has single citizenship to promote unity. No separate state citizenship.',
          keyPoints: [
            'Case Law: Pradeep Jain v Union of India.',
          ],
        ),
      ],
      caseLaws: [
        CaseLaw(id: 'cl3_1', unitId: 'unit3', name: 'State of West Bengal v Union of India', year: '1963', court: 'Supreme Court', facts: 'Acquisition of coal bearing lands.', held: 'Strong centre powers.', significance: 'Not a traditional federation.'),
        CaseLaw(id: 'cl3_2', unitId: 'unit3', name: 'Babulal Parate v State of Bombay', year: '1960', court: 'Supreme Court', facts: 'Reorganisation of Bombay.', held: 'Parliament authority over state boundaries.', significance: 'Art 3 supremacy.'),
        CaseLaw(id: 'cl3_3', unitId: 'unit3', name: 'Pradeep Jain v Union of India', year: '1984', court: 'Supreme Court', facts: 'Residence requirement for medical admission.', held: 'Single citizenship concept.', significance: 'Unity of India.'),
      ],
    );
  }

  static Unit _unit4() {
    return Unit(
      id: 'unit4', number: 4,
      title: 'Fundamental Rights',
      description: 'Articles 12 to 35, the Magna Carta of the Indian Constitution.',
      color: '#9C6644',
      topics: [
        Topic(
          id: 'u4_t1', unitId: 'unit4',
          title: 'ART 12 & 13',
          content: 'Art 12: Definition of State (Govt, Parliament, State Legislature, Local bodies). Art 13: Laws inconsistent with FR are void (Judicial Review).',
          keyPoints: [
            'Case: Rajasthan Electricity Board v Mohan Lal (Other authorities).',
            'Case: Keshavan Madhava Menon v State of Bombay (Doctrine of Eclipse).',
          ],
        ),
        Topic(
          id: 'u4_t2', unitId: 'unit4',
          title: 'RIGHT TO EQUALITY (ART 14-18)',
          content: 'Art 14: Equality before law. Art 15: No discrimination. Art 16: Public employment opportunity. Art 17: Abolition of untouchability. Art 18: Abolition of titles.',
          keyPoints: [
            'Case Law: Indra Sawhney v Union of India (Mandal Case).',
          ],
        ),
        Topic(
          id: 'u4_t3', unitId: 'unit4',
          title: 'RIGHT TO FREEDOM (ART 19-22)',
          content: 'Art 19: Six freedoms (speech, assembly, etc). Art 20: Protection for offences. Art 21: Life and personal liberty. Art 22: Arrest protection.',
          keyPoints: [
            'Case Law: Maneka Gandhi v Union of India (expanded Art 21).',
            'Case Law: A.K. Gopalan v State of Madras (original narrow view).',
          ],
        ),
        Topic(
          id: 'u4_t4', unitId: 'unit4',
          title: 'EXPLOITATION, RELIGION, CULTURE',
          content: 'Art 23-24: Against exploitation. Art 25-28: Religious freedom. Art 29-30: Minority rights.',
          keyPoints: [
            'Case: People\'s Union for Democratic Rights v UOI (Art 23).',
            'Case: Shirur Mutt (Art 25).',
            'Case: St Xavier\'s College (Art 30).',
          ],
        ),
        Topic(
          id: 'u4_t5', unitId: 'unit4',
          title: 'CONSTITUTIONAL REMEDIES (ART 32)',
          content: 'Right to move SC for FR enforcement. Writs: Habeas Corpus, Mandamus, Prohibition, Certiorari, Quo-Warranto.',
          keyPoints: [
            'Illustration: Violation → Court → Remedy',
          ],
        ),
        Topic(
          id: 'u4_t6', unitId: 'unit4',
          title: 'DOCTRINES',
          content: 'Severability (only bad part void), Eclipse (dormant pre-constitutional law), Waiver (cannot give up FR).',
          keyPoints: [
            'Case: R.M.D. Chamarbaugwala (Severability).',
            'Case: Bhikaji Narain (Eclipse).',
            'Case: Basheshar Nath v CIT (Waiver).',
          ],
        ),
      ],
      caseLaws: [
        CaseLaw(id: 'cl4_1', unitId: 'unit4', name: 'Maneka Gandhi v Union of India', year: '1978', court: 'Supreme Court', facts: 'Passport impounded.', held: 'Procedure must be fair, just and reasonable.', significance: 'Golden Triangle (14, 19, 21).'),
        CaseLaw(id: 'cl4_2', unitId: 'unit4', name: 'Indra Sawhney v Union of India', year: '1992', court: 'Supreme Court', facts: 'OBC Reservation.', held: 'Reservation limited to 50%, Creamy layer excluded.', significance: 'Equality check.'),
        CaseLaw(id: 'cl4_3', unitId: 'unit4', name: 'A.K. Gopalan v State of Madras', year: '1950', court: 'Supreme Court', facts: 'Detention check.', held: 'Restrictive view of Art 21.', significance: 'Later overruled.'),
      ],
    );
  }

  static Unit _unit5() {
    return Unit(
      id: 'unit5', number: 5,
      title: 'DPSP & Fundamental Duties',
      description: 'Directive Principles (Part IV) and Fundamental Duties (Part IVA).',
      color: '#7F5539',
      topics: [
        Topic(
          id: 'u5_t1', unitId: 'unit5',
          title: 'DIRECTIVE PRINCIPLES (DPSP)',
          content: 'Art 36-51. Guidelines for welfare state. Non-justiciable but fundamental in governance.',
          keyPoints: [
            'Classification: Socialistic, Gandhian, Liberal.',
            'Case Law: State of Madras v Champakam Dorairajan (FR vs DPSP).',
          ],
        ),
        Topic(
          id: 'u5_t2', unitId: 'unit5',
          title: 'DPSP CATEGORIES',
          content: 'Socialistic: Equal pay, wealth prev. Gandhian: Village Panchayats, cottage industries. Liberal: UCC (Art 44), Environment, Judiciary separation.',
          keyPoints: [
            'Example: Midday meal, Panchayati Raj.',
            'Case: Randhir Singh (Equal pay).',
            'Case: M.C. Mehta (Environment).',
          ],
        ),
        Topic(
          id: 'u5_t3', unitId: 'unit5',
          title: 'FR vs DPSP RELATION',
          content: 'Harmony and balance. FR protects individual, DPSP promotes social welfare.',
          keyPoints: [
            'Case Law: Minerva Mills v Union of India (Harmony is Basic Structure).',
            'Case Law: Golaknath (Initially gave priority to FR).',
          ],
        ),
        Topic(
          id: 'u5_t4', unitId: 'unit5',
          title: 'FUNDAMENTAL DUTIES',
          content: 'Art 51A. Added by 42nd Amendment 1976. Swaran Singh Committee. 11 duties (last added by 86th Am).',
          keyPoints: [
            'Example: Respect National Flag, Protect environment.',
            'Case: AIIMS Students Union v AIIMS.',
          ],
        ),
      ],
      caseLaws: [
        CaseLaw(id: 'cl5_1', unitId: 'unit5', name: 'Minerva Mills v Union of India', year: '1980', court: 'Supreme Court', facts: 'Extension of directive principles.', held: 'Balance between FR and DPSP is part of Basic Structure.', significance: 'Constitutional balance.'),
        CaseLaw(id: 'cl5_2', unitId: 'unit5', name: 'State of Madras v Champakam Dorairajan', year: '1951', court: 'Supreme Court', facts: 'Communal reservation.', held: 'FR prevails over DPSP in case of conflict.', significance: 'Historical priority.'),
      ],
    );
  }

  static Unit _unit6() {
    return Unit(
      id: 'unit6', number: 6,
      title: 'Amendment & Basic Structure',
      description: 'Article 368 and the doctrine that protects the soul of the Constitution.',
      color: '#4A6FA5',
      topics: [
        Topic(
          id: 'u6_t1', unitId: 'unit6',
          title: 'AMENDMENT PROCEDURE (ART 368)',
          content: 'Parliament can amend but cannot destroy basic structure. Three types: Simple majority, Special majority, Special + State ratification.',
          keyPoints: [
            'Example: Right to property removal (44th Am).',
            'Illustration: Bill → Parliament → President → Amendment',
          ],
        ),
        Topic(
          id: 'u6_t2', unitId: 'unit6',
          title: 'BASIC STRUCTURE DOCTRINE',
          content: 'Judicial innovation to limit amendment power. Essential features cannot be removed (Democracy, Secularism, Rule of Law, Judicial Review).',
          keyPoints: [
            'Case Law: Kesavananda Bharati (1973).',
            'Case Law: I.R. Coelho (9th Schedule review).',
          ],
        ),
        Topic(
          id: 'u6_t3', unitId: 'unit6',
          title: 'CASE EVOLUTION',
          content: 'Golaknath (Parliament cannot amend FR). Kesavananda (Can amend but not Basic Structure). Minerva Mills (Limited power is Basic Structure).',
          keyPoints: [
            'Illustration: Unlimited Power → Restricted → Basic Structure',
          ],
        ),
      ],
      caseLaws: [
        CaseLaw(id: 'cl6_1', unitId: 'unit6', name: 'Kesavananda Bharati v State of Kerala', year: '1973', court: 'Supreme Court', facts: 'Validity of amendments.', held: 'Basic Structure Doctrine established.', significance: 'Saved Indian democracy.'),
        CaseLaw(id: 'cl6_2', unitId: 'unit6', name: 'Minerva Mills v Union of India', year: '1980', court: 'Supreme Court', facts: '42nd Amendment sections 4 and 55.', held: 'Parliament cannot give itself unlimited power.', significance: 'Reinforced Kesavananda.'),
        CaseLaw(id: 'cl6_3', unitId: 'unit6', name: 'I.R. Coelho v State of Tamil Nadu', year: '2007', court: 'Supreme Court', facts: '9th Schedule immunity.', held: '9th schedule laws subject to basic structure test.', significance: 'No blanket immunity.'),
      ],
    );
  }
}
