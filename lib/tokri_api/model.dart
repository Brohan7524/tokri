import 'dart:math';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> generateWeeklyBasket(int familySize) {
  final now = DateTime.now();
  final int month = now.month;
  String season;

  if (month >= 3 && month <= 5) {
    season = 'summer';
  } else if (month >= 6 && month <= 9) {
    season = 'monsoon';
  } else {
    season = 'winter';
  }

  final produceBySeason = {
    'summer': {
      'fruits': ['mango', 'papaya', 'watermelon', 'jamun'],
      'vegetables': ['cucumber', 'bottle gourd', 'ridge gourd', 'brinjal']
    },
    'monsoon': {
      'fruits': ['guava', 'custard apple', 'pear'],
      'vegetables': ['okra', 'beans', 'spinach', 'methi']
    },
    'winter': {
      'fruits': ['orange', 'grapes', 'kiwi'],
      'vegetables': ['carrot', 'beetroot', 'cabbage', 'cauliflower']
    }
  };

  final staples = ['potato', 'tomato', 'onion'];
  final sprouts = ['moong sprouts', 'matki sprouts', 'kala chana sprouts'];
  final pulses = [
    'rajma', 'kabuli chana', 'toor dal', 'lobia', 'masoor dal', 'horse gram', 'moth beans'
  ];
  final cookingEssentials = [
    'green chili',
    'fresh ginger',
    'garlic',
    'coriander leaves',
    'curry leaves',
    'spring onion',
    'mint leaves',
    'raw turmeric',
    'lime/lemon',
    'raw mango'
  ];

  final random = Random();
  final weeklyBasket = <Map<String, dynamic>>[];
  final stapleCount = {for (var s in staples) s: 0};

  final pulseDays = List.generate(7, (i) => i)..shuffle();
  final sproutDays = List.generate(7, (i) => i)..shuffle();

  for (int day = 0; day < 7; day++) {
    final fruits = List.of(produceBySeason[season]!['fruits']!)..shuffle();
    final otherVeggies = List.of(produceBySeason[season]!['vegetables']!)..shuffle();

    List<String> selectedVeggies = [];
    for (var s in staples) {
      if (stapleCount[s]! < 3 && random.nextDouble() < 0.4) {
        selectedVeggies.add(s);
        stapleCount[s] = stapleCount[s]! + 1;
      }
    }
    for (var veg in otherVeggies) {
      if (selectedVeggies.length >= 4) break;
      if (!selectedVeggies.contains(veg)) selectedVeggies.add(veg);
    }

    if (day == 6) {
      for (var s in staples) {
        if (stapleCount[s]! < 3) {
          selectedVeggies[random.nextInt(4)] = s;
          stapleCount[s] = stapleCount[s]! + 1;
        }
      }
    }

    final breakfastItems = {
      'fruits': [fruits[0]],
      'sprouts': sproutDays.sublist(0, 5).contains(day)
          ? '${sprouts[random.nextInt(sprouts.length)]} (${familySize * 100}g)'
          : null
    };

    final pulse = pulseDays.sublist(0, 4).contains(day)
        ? pulses[random.nextInt(pulses.length)]
        : null;

    final cookingItems = List.of(cookingEssentials)..shuffle();

    final basket = {
      'day': 'Day ${day + 1}',
      'breakfast': breakfastItems,
      'lunch': {
        'vegetables': selectedVeggies.sublist(0, 2),
        'pulse': random.nextBool() ? pulse : null,
        'rice': familySize * 150,
        'roti': familySize * 2
      },
      'snack': {
        'fruit': fruits[1]
      },
      'dinner': {
        'vegetables': selectedVeggies.sublist(2, 4),
        'pulse': random.nextBool() ? pulse : null,
        'roti': familySize * 2
      },
      'cooking_ingredients': cookingItems.sublist(0, 4)
    };

    weeklyBasket.add(basket);
  }

  return weeklyBasket;
}
