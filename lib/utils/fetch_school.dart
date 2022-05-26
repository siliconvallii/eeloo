String fetchSchool(email) {
  // Fetch email domain
  List<String> emailStrings = email.split('@');
  String emailDomain = emailStrings[1];

  String school = '';

  // Check which school uses that emailDomain
  if (emailDomain == 'studenti.liceosarpi.bg.it') {
    school = 'Liceo P. Sarpi';
  } else if (emailDomain == 'studenti.lasbg.com') {
    school = 'Liceo G. Manzù';
  } else if (emailDomain == 'liceolussana.eu') {
    school = 'Liceo F. Lussana';
  } else if (emailDomain == 'studenti.liceomascheroni.it') {
    school = 'Liceo L. Mascheroni';
  }

  return school;
}
