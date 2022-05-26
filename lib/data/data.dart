import 'package:flutter/material.dart';

Map user = {};

Map<String, dynamic> users = {};

String localVersion = '1.4.5+26';

List<String> allowedEmailDomains = [
  // Liceo P. Sarpi
  'studenti.liceosarpi.bg.it',
  // Liceo G. Manzù
  'studenti.lasbg.com',
  // Liceo F. Lussana
  'liceolussana.eu',
  // Liceo L. Mascheroni
  'studenti.liceomascheroni.it'
];

List<DropdownMenuItem<String>> classes = const [
  DropdownMenuItem(
    child: Text('I'),
    value: 'I',
  ),
  DropdownMenuItem(
    child: Text('II'),
    value: 'II',
  ),
  DropdownMenuItem(
    child: Text('III'),
    value: 'III',
  ),
  DropdownMenuItem(
    child: Text('IV'),
    value: 'IV',
  ),
  DropdownMenuItem(
    child: Text('V'),
    value: 'V',
  ),
];

List<DropdownMenuItem<String>> sections = const [
  DropdownMenuItem(
    child: Text('A'),
    value: 'A',
  ),
  DropdownMenuItem(
    child: Text('AS'),
    value: 'AS',
  ),
  DropdownMenuItem(
    child: Text('B'),
    value: 'B',
  ),
  DropdownMenuItem(
    child: Text('BS'),
    value: 'BS',
  ),
  DropdownMenuItem(
    child: Text('C'),
    value: 'C',
  ),
  DropdownMenuItem(
    child: Text('CS'),
    value: 'CS',
  ),
  DropdownMenuItem(
    child: Text('D'),
    value: 'D',
  ),
  DropdownMenuItem(
    child: Text('DS'),
    value: 'DS',
  ),
  DropdownMenuItem(
    child: Text('E'),
    value: 'E',
  ),
  DropdownMenuItem(
    child: Text('ES'),
    value: 'ES',
  ),
  DropdownMenuItem(
    child: Text('F'),
    value: 'F',
  ),
  DropdownMenuItem(
    child: Text('FS'),
    value: 'FS',
  ),
  DropdownMenuItem(
    child: Text('G'),
    value: 'G',
  ),
  DropdownMenuItem(
    child: Text('GS'),
    value: 'GS',
  ),
  DropdownMenuItem(
    child: Text('H'),
    value: 'H',
  ),
  DropdownMenuItem(
    child: Text('HS'),
    value: 'HS',
  ),
  DropdownMenuItem(
    child: Text('I'),
    value: 'I',
  ),
  DropdownMenuItem(
    child: Text('IS'),
    value: 'IS',
  ),
  DropdownMenuItem(
    child: Text('L'),
    value: 'L',
  ),
  DropdownMenuItem(
    child: Text('LS'),
    value: 'LS',
  ),
  DropdownMenuItem(
    child: Text('M'),
    value: 'M',
  ),
  DropdownMenuItem(
    child: Text('MS'),
    value: 'MS',
  ),
  DropdownMenuItem(
    child: Text('N'),
    value: 'N',
  ),
  DropdownMenuItem(
    child: Text('NS'),
    value: 'NS',
  ),
  DropdownMenuItem(
    child: Text('O'),
    value: 'O',
  ),
  DropdownMenuItem(
    child: Text('OS'),
    value: 'OS',
  ),
  DropdownMenuItem(
    child: Text('P'),
    value: 'P',
  ),
  DropdownMenuItem(
    child: Text('PS'),
    value: 'PS',
  ),
  DropdownMenuItem(
    child: Text('Q'),
    value: 'Q',
  ),
  DropdownMenuItem(
    child: Text('QS'),
    value: 'QS',
  ),
  DropdownMenuItem(
    child: Text('R'),
    value: 'R',
  ),
  DropdownMenuItem(
    child: Text('RS'),
    value: 'RS',
  ),
  DropdownMenuItem(
    child: Text('S'),
    value: 'S',
  ),
  DropdownMenuItem(
    child: Text('SS'),
    value: 'SS',
  ),
  DropdownMenuItem(
    child: Text('T'),
    value: 'T',
  ),
  DropdownMenuItem(
    child: Text('TS'),
    value: 'TS',
  ),
  DropdownMenuItem(
    child: Text('U'),
    value: 'U',
  ),
  DropdownMenuItem(
    child: Text('US'),
    value: 'US',
  ),
  DropdownMenuItem(
    child: Text('V'),
    value: 'V',
  ),
  DropdownMenuItem(
    child: Text('VS'),
    value: 'VS',
  ),
  DropdownMenuItem(
    child: Text('Z'),
    value: 'Z',
  ),
  DropdownMenuItem(
    child: Text('ZS'),
    value: 'ZS',
  ),
];
