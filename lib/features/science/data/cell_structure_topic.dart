import 'package:flutter/material.dart';

import '../models/science_content.dart';

/// "Cell Structure" reading-comprehension topic.
const ScienceTopic kCellStructureTopic = ScienceTopic(
  id: 'cell_structure',
  title: 'Cell Structure',
  tagline: 'Reading comprehension in cell biology',
  intro:
      'Each activity begins with a short passage and its diagram. Read the '
      'passage, then answer the questions that follow — every answer can be '
      'found in what you have just read.',
  heroImage: 'assets/animal_cell.png',
  accent: Color(0xFF2E7D32),
  quiz: ReadingActivity(
    passageTitle: 'Passage 1: Inside a Human Cell',
    passageText:
        'A human cell is wrapped in a plasma membrane, and the space inside it '
        'is filled with a jelly-like fluid called cytoplasm. Floating in that '
        'cytoplasm are small working parts called organelles, and each one has '
        'its own job. The nucleus is the control centre of the cell; it is '
        'held inside a nuclear membrane and contains a dense spot called the '
        'nucleolus. Mitochondria release the energy the cell needs, which is '
        'why they are often called its powerhouses. Ribosomes build proteins. '
        'The rough endoplasmic reticulum is studded with ribosomes, while the '
        'smooth endoplasmic reticulum has none. The Golgi complex packages the '
        'finished proteins, and lysosomes hold enzymes that break down '
        'worn-out material. Fingerlike microvilli on the outside of the cell '
        'increase the surface through which it can absorb substances.',
    diagram: 'assets/animal_cell.png',
    diagramCaption: 'Figure 1 — Human cell anatomy',
  ),
  blanks: ReadingActivity(
    passageTitle: 'Passage 2: Two Kinds of Cell',
    passageText:
        'Living cells come in two main kinds. A prokaryotic cell, such as a '
        'bacterium, has no nucleus. Its genetic material is a single ring of '
        'DNA lying loose in the cytoplasm, often alongside small extra loops '
        'called plasmids. The cell is enclosed by a plasma membrane and a '
        'tough cell wall, and many prokaryotes are wrapped in an outer '
        'capsule. Short hairs called pili cover the surface, and a long tail '
        'called a flagellum drives the cell forward. A eukaryotic cell is '
        'larger and keeps its DNA inside a true nucleus. It also contains '
        'membrane-bound organelles that prokaryotes lack, such as '
        'mitochondria, a Golgi apparatus and endoplasmic reticulum. Both kinds '
        'of cell contain ribosomes and cytoplasm.',
    diagram: 'assets/cell_types.png',
    diagramCaption: 'Figure 2 — Prokaryotic and eukaryotic cells compared',
  ),
  wordBank: [
    'plasma membrane', 'cytoplasm', 'organelle', 'nucleus', 'nucleolus',
    'mitochondria', 'ribosome', 'Golgi complex', 'lysosome', 'microvilli',
    'prokaryotic', 'eukaryotic', 'plasmid', 'capsule', 'pili', 'flagellum',
  ],
  questions: [
    QuizQuestion(
      question: 'What wraps around the outside of a human cell?',
      options: ['The nuclear membrane', 'The plasma membrane', 'The cell wall'],
      answerIndex: 1,
      explanation:
          'The passage opens by saying a human cell is wrapped in a plasma '
          'membrane.',
    ),
    QuizQuestion(
      question: 'What is the jelly-like fluid inside the cell called?',
      options: ['Cytoplasm', 'Nucleolus', 'Plasma'],
      answerIndex: 0,
      explanation:
          'The space inside the membrane is filled with a jelly-like fluid '
          'called cytoplasm.',
    ),
    QuizQuestion(
      question: 'What name is given to the small working parts of a cell?',
      options: ['Organs', 'Organelles', 'Enzymes'],
      answerIndex: 1,
      explanation:
          'The small working parts floating in the cytoplasm are called '
          'organelles, and each has its own job.',
    ),
    QuizQuestion(
      question: 'Which organelle is the control centre of the cell?',
      options: ['The nucleus', 'The Golgi complex', 'A lysosome'],
      answerIndex: 0,
      explanation:
          'The nucleus is described as the control centre, held inside a '
          'nuclear membrane.',
    ),
    QuizQuestion(
      question: 'What is the dense spot found inside the nucleus?',
      options: ['A ribosome', 'A vacuole', 'The nucleolus'],
      answerIndex: 2,
      explanation: 'The nucleus contains a dense spot called the nucleolus.',
    ),
    QuizQuestion(
      question: 'Which organelles are often called the powerhouses?',
      options: ['Lysosomes', 'Mitochondria', 'Ribosomes'],
      answerIndex: 1,
      explanation:
          'Mitochondria release the energy the cell needs, so they are called '
          'its powerhouses.',
    ),
    QuizQuestion(
      question: 'What do ribosomes build?',
      options: ['Proteins', 'Sugars', 'Membranes'],
      answerIndex: 0,
      explanation: 'The passage states simply that ribosomes build proteins.',
    ),
    QuizQuestion(
      question: 'How does rough endoplasmic reticulum differ from smooth?',
      options: [
        'Rough is studded with ribosomes; smooth has none',
        'Rough is inside the nucleus; smooth is outside',
        'Rough packages proteins; smooth stores them',
      ],
      answerIndex: 0,
      explanation:
          'Rough ER is studded with ribosomes, while smooth ER has none — that '
          'is what makes it look smooth.',
    ),
    QuizQuestion(
      question: 'What does the Golgi complex do?',
      options: [
        'Breaks down worn-out material',
        'Packages the finished proteins',
        'Releases energy',
      ],
      answerIndex: 1,
      explanation:
          'The Golgi complex packages the finished proteins; breaking down '
          'worn-out material is the job of lysosomes.',
    ),
    QuizQuestion(
      question: 'Why does a cell have microvilli?',
      options: [
        'To move the cell along',
        'To hold the nucleus in place',
        'To increase the surface for absorbing substances',
      ],
      answerIndex: 2,
      explanation:
          'Fingerlike microvilli increase the surface through which the cell '
          'can absorb substances.',
    ),
  ],
  blankItems: [
    BlankItem(
      before: 'A bacterium is an example of a ',
      after: ' cell.',
      accepted: ['prokaryotic', 'prokaryote'],
      hint: 'The kind of cell shown on the left of the figure.',
    ),
    BlankItem(
      before: 'A prokaryotic cell has no ',
      after: '.',
      accepted: ['nucleus'],
      hint: 'The structure a eukaryotic cell keeps its DNA inside.',
    ),
    BlankItem(
      before: 'Its genetic material is a single ring of ',
      after: ' lying loose in the cytoplasm.',
      accepted: ['DNA'],
      hint: 'Three letters.',
    ),
    BlankItem(
      before: 'Small extra loops of genetic material are called ',
      after: '.',
      accepted: ['plasmids', 'plasmid'],
      hint: 'It begins with "plas".',
    ),
    BlankItem(
      before: 'Outside the plasma membrane lies a tough ',
      after: '.',
      accepted: ['cell wall'],
      hint: 'Two words; plants have one too.',
    ),
    BlankItem(
      before: 'Many prokaryotes are also wrapped in an outer ',
      after: '.',
      accepted: ['capsule'],
      hint: 'The outermost green layer in the figure.',
    ),
    BlankItem(
      before: 'Short hairs that cover the surface are called ',
      after: '.',
      accepted: ['pili', 'pilus'],
      hint: 'Four letters, ending in i.',
    ),
    BlankItem(
      before: 'The long tail that drives the cell forward is called a ',
      after: '.',
      accepted: ['flagellum', 'flagella'],
      hint: 'It begins with "fla".',
    ),
    BlankItem(
      before: 'A eukaryotic cell keeps its DNA inside a true ',
      after: '.',
      accepted: ['nucleus'],
      hint: 'The control centre of the cell.',
    ),
    BlankItem(
      before: 'Eukaryotes contain membrane-bound ',
      after: ' that prokaryotes lack.',
      accepted: ['organelles', 'organelle'],
      hint: 'The general word for a cell\'s working parts.',
    ),
    BlankItem(
      before: 'Examples include mitochondria, endoplasmic reticulum and a ',
      after: ' apparatus.',
      accepted: ['Golgi'],
      hint: 'Named after the scientist Camillo ______.',
    ),
    BlankItem(
      before: 'Both kinds of cell contain cytoplasm and ',
      after: '.',
      accepted: ['ribosomes', 'ribosome'],
      hint: 'The organelles that build proteins.',
    ),
  ],
);
