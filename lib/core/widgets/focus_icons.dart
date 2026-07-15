// ═══════════════════════════════════════════════════════════════
// FOCUSKEY — MODE ICON SET (50 icons, final)
// ═══════════════════════════════════════════════════════════════
// One file, no assets. Icons are compiled-in SVG strings rendered
// via flutter_svg — nothing fetched at runtime (keeps the app
// fully offline / no-network, per product promise).
//
// DEPENDENCY (pubspec.yaml):
//   flutter_svg: ^2.0.10
//
// USAGE:
//   FocusIcon(FKIcon.gym)                         // default 26px, warm grey
//   FocusIcon(FKIcon.sleep, size: 32, color: ...) // any size/tint
//   ModeIconTile(icon: FKIcon.run, selected: true, onTap: ...)
//
// SYSTEM: 24×24 viewBox · 1.5 stroke · round caps/joins · outline
// only · no human figures. Do not mix icons from other sets into
// this grid — the stroke weight will clash.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icon tokens (match the mode-edit screen).
class FKIconColors {
  static const stroke = Color(0xFF8A8278); // resting
  static const strokeSelected = Color(0xFF8A7350); // on gold tile
  static const tileBorder = Color(0xFFE5E1D5);
  static const selectedBorder = Color(0xFFC4A97D);
  static const selectedBg = Color(0xFFECE5D4);
}

enum FKIcon {
  // Work & study
  work, deepwork, study, write, school, create, journal, read, world, thelab,
  // Body
  gym, run, ride, swim, yoga, health,
  // Rest & rituals
  sleep, winddown, morning, evening, quiet, dnd, mindful, deeptime, timer,
  // Food & screen-off evenings
  meals, cook, brew, movie,
  // Home & life
  family, home, pets, garden, celebrate, cards,
  // Out & away
  travel, explore, football, outdoors, adventure, sunshine,
  // Play & craft
  art, music, listen, photo, game, play, puzzle,
  // Marks
  favourite, totalFocus,
}

const String _p =
    'fill="none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"';

/// Raw geometry per icon. Stroke color is applied via ColorFilter,
/// so the hardcoded stroke here is just a placeholder.
const Map<FKIcon, String> _svg = {
  // ── WORK & STUDY ──
  FKIcon.work:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="4" y="8" width="16" height="11" rx="2"/><path d="M9 8V6a2 2 0 012-2h2a2 2 0 012 2v2M4 13h16"/></g></svg>',
  FKIcon.deepwork:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="5" y="5" width="14" height="9" rx="1.5"/><path d="M5 14l-1.5 3.5h17L19 14"/></g></svg>',
  FKIcon.study:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 6c-1.5-1.3-3.5-2-6-2v14c2.5 0 4.5.7 6 2 1.5-1.3 3.5-2 6-2V4c-2.5 0-4.5.7-6 2z"/><path d="M12 6v14"/></g></svg>',
  FKIcon.write:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M4 20l1-4L16.5 4.5a2.12 2.12 0 013 3L8 19l-4 1z"/><path d="M14 7l3 3"/></g></svg>',
  FKIcon.school:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 4L2 9l10 5 10-5-10-5z"/><path d="M6 11.5V16c0 1.5 2.7 3 6 3s6-1.5 6-3v-4.5M22 9v5"/></g></svg>',
  FKIcon.create:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 3a6 6 0 00-4 10.5c.8.7 1.3 1.5 1.5 2.5h5c.2-1 .7-1.8 1.5-2.5A6 6 0 0012 3z"/><path d="M9.5 19h5M10.5 21.5h3"/></g></svg>',
  FKIcon.journal:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="6" y="3.5" width="13" height="17" rx="2"/><path d="M4.5 7H7M4.5 12H7M4.5 17H7"/></g></svg>',
  FKIcon.read:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="7" cy="14" r="3.2"/><circle cx="17" cy="14" r="3.2"/><path d="M10.2 13.4c.6-1 3-1 3.6 0M3.9 12.6L3 10M20.1 12.6L21 10"/></g></svg>',
  FKIcon.world:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17M12 3.5c2.8 2.3 4.2 5.1 4.2 8.5s-1.4 6.2-4.2 8.5c-2.8-2.3-4.2-5.1-4.2-8.5s1.4-6.2 4.2-8.5z"/></g></svg>',
  FKIcon.thelab:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M9.5 3.5h5M10.5 3.5v5l-5 8.5a2.3 2.3 0 002 3.5h9a2.3 2.3 0 002-3.5l-5-8.5v-5"/><path d="M7.8 14.5h8.4"/></g></svg>',

  // ── BODY ──
  FKIcon.gym:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M2.5 12h1.5M20 12h1.5M7 12h10"/><rect x="4" y="8" width="3" height="8" rx="1"/><rect x="17" y="8" width="3" height="8" rx="1"/></g></svg>',
  FKIcon.run:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M3 16.5c0-1 .6-2 1.6-2.4L9 12l2 1.4c1 .7 2.2 1.1 3.4 1.1H19a2 2 0 012 2v1H3v-1z"/><path d="M3 17.5h18M10.8 13.6l1-1.2M13 14.5l1-1.2"/></g></svg>',
  FKIcon.ride:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="6" cy="16" r="3.2"/><circle cx="18" cy="16" r="3.2"/><path d="M6 16l3.4-6h5.2L18 16M9.4 10L8.2 7h2.3M14.6 10l-1-2.8"/></g></svg>',
  FKIcon.swim:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M3 10c2 0 2-1.5 4.5-1.5S9.5 10 12 10s2.5-1.5 5-1.5S19 10 21 10"/><path d="M3 15.5c2 0 2-1.5 4.5-1.5s2 1.5 4.5 1.5 2.5-1.5 5-1.5 2 1.5 4 1.5"/></g></svg>',
  FKIcon.yoga:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 6c-1.5 1.8-2.3 3.4-2.3 5a2.3 2.3 0 004.6 0c0-1.6-.8-3.2-2.3-5z"/><path d="M7 9.5c-.6 2.8.3 5 2.8 6.2M17 9.5c.6 2.8-.3 5-2.8 6.2"/><path d="M4.5 14c1.5 3 4 4.5 7.5 4.5s6-1.5 7.5-4.5"/></g></svg>',
  FKIcon.health:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M20.8 6.6a5.4 5.4 0 00-7.7 0l-1.1 1-1-1a5.4 5.4 0 00-7.7 7.7l8.7 8.7 8.8-8.7a5.4 5.4 0 000-7.7z"/></g></svg>',

  // ── REST & RITUALS ──
  FKIcon.sleep:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M20.5 14.5A8.5 8.5 0 019.5 3.5a8.5 8.5 0 1011 11z"/></g></svg>',
  FKIcon.winddown:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M3 19v-9M3 12h18v7M3 16h18"/><path d="M6 12V9.5A1.5 1.5 0 017.5 8h3A1.5 1.5 0 0112 9.5V12"/></g></svg>',
  FKIcon.morning:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M6 17a6 6 0 0112 0M2.5 17H5M19 17h2.5M12 3.5V6M5.2 7.2L7 9M18.8 7.2L17 9"/></g></svg>',
  FKIcon.evening:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 13a4 4 0 014 4H8a4 4 0 014-4zM3 17h2M19 17h2M12 8v2.5M5.6 10.6L7 12M18.4 10.6L17 12M8 21h8"/></g></svg>',
  FKIcon.quiet:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 3.5c-1.1 1.4-1.9 2.4-1.9 3.5a1.9 1.9 0 003.8 0c0-1.1-.8-2.1-1.9-3.5z"/><path d="M12 9v2M9.5 11.5h5a1 1 0 011 1V19a1.5 1.5 0 01-1.5 1.5h-4A1.5 1.5 0 018.5 19v-6.5a1 1 0 011-1z"/></g></svg>',
  FKIcon.dnd:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M6.5 10a5.5 5.5 0 0111 0c0 3 .8 4.5 1.8 5.5H4.7c1-1 1.8-2.5 1.8-5.5z"/><path d="M10.2 18.5a1.9 1.9 0 003.6 0M4.5 4.5l15 15"/></g></svg>',
  FKIcon.mindful:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M11 3.5c.4 3.4 1.8 4.8 5.2 5.2-3.4.4-4.8 1.8-5.2 5.2-.4-3.4-1.8-4.8-5.2-5.2 3.4-.4 4.8-1.8 5.2-5.2z"/><path d="M17.8 13.8c.2 1.9 1 2.7 2.9 2.9-1.9.2-2.7 1-2.9 2.9-.2-1.9-1-2.7-2.9-2.9 1.9-.2 2.7-1 2.9-2.9z"/></g></svg>',
  FKIcon.deeptime:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M6.5 3.5h11M6.5 20.5h11"/><path d="M7.5 3.5v2.5c0 2.5 2 3.7 4.5 6-2.5 2.3-4.5 3.5-4.5 6v2.5M16.5 3.5v2.5c0 2.5-2 3.7-4.5 6 2.5 2.3 4.5 3.5 4.5 6v2.5"/></g></svg>',
  FKIcon.timer:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="12" cy="12" r="8.5"/><path d="M12 7v5l3.5 2"/></g></svg>',

  // ── FOOD & SCREEN-OFF EVENINGS ──
  FKIcon.meals:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M4 12a8 8 0 0016 0H4zM4 12h16M9 19.5h6"/><path d="M9.5 7.5c-.8-.8-.8-1.7 0-2.5M14.5 7.5c-.8-.8-.8-1.7 0-2.5"/></g></svg>',
  FKIcon.cook:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M6.8 9.3A3.3 3.3 0 018 3.2a4.6 4.6 0 018 0 3.3 3.3 0 011.2 6.1V14H6.8V9.3z"/><path d="M6.8 14v3h10.4v-3"/></g></svg>',
  FKIcon.brew:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M5 9h10v6a4 4 0 01-4 4H9a4 4 0 01-4-4V9zM15 10h1.5a2.5 2.5 0 010 5H15"/><path d="M8.5 3.5V6M11.5 3.5V6"/></g></svg>',
  FKIcon.movie:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="4" y="8" width="16" height="11" rx="2"/><path d="M9 4.5l3 3 3-3"/></g></svg>',

  // ── HOME & LIFE ──
  FKIcon.family:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="9" cy="8.5" r="2.7"/><path d="M3.5 19c.5-3.2 2.7-5 5.5-5s5 1.8 5.5 5"/><circle cx="17" cy="9.5" r="2"/><path d="M16 14.3c2.3.3 4 1.9 4.5 4.7"/></g></svg>',
  FKIcon.home:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M4 11l8-7 8 7M6 9.5V19h12V9.5M10 19v-5h4v5"/></g></svg>',
  FKIcon.pets:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 13c-2.3 0-4.1 1.6-4.1 3.5 0 1.4 1 2.2 2.2 2.2.7 0 1.3-.3 1.9-.3s1.2.3 1.9.3c1.2 0 2.2-.8 2.2-2.2 0-1.9-1.8-3.5-4.1-3.5z"/><circle cx="7" cy="10" r="1.3"/><circle cx="10" cy="7.6" r="1.4"/><circle cx="14" cy="7.6" r="1.4"/><circle cx="17" cy="10" r="1.3"/></g></svg>',
  FKIcon.garden:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M8 14h8l-.8 6H8.8L8 14zM12 14v-3"/><path d="M12 11c0-2.1-1.5-3.6-3.9-3.6.2 2.4 1.7 3.6 3.9 3.6zM12 11c0-2.1 1.5-3.6 3.9-3.6-.2 2.4-1.7 3.6-3.9 3.6z"/></g></svg>',
  FKIcon.celebrate:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="4.5" y="9.5" width="15" height="10.5" rx="1"/><path d="M12 9.5V20M3.5 6.5h17v3h-17z"/><path d="M12 6.5c-1-2.6-4.5-3-4.5-.9 0 1.4 2.2 1 4.5.9zM12 6.5c1-2.6 4.5-3 4.5-.9 0 1.4-2.2 1-4.5.9z"/></g></svg>',
  FKIcon.cards:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><g transform="rotate(-10 9 11)"><rect x="4.8" y="4.5" width="8.6" height="12.6" rx="1.4"/></g><g transform="rotate(8 15 13)"><rect x="10.6" y="6.4" width="8.6" height="12.6" rx="1.4"/><path d="M14.9 10.6l1.6 2.1-1.6 2.1-1.6-2.1z"/></g></g></svg>',

  // ── OUT & AWAY ──
  FKIcon.travel:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M21 12c0-.8-.7-1.5-1.5-1.5H15L10 3H8l2.5 7.5H5.5L4 8.5H2.5L4 12l-1.5 3.5H4l1.5-2h5L8 21h2l5-7.5h4.5c.8 0 1.5-.7 1.5-1.5z"/></g></svg>',
  FKIcon.explore:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="12" cy="12" r="8.5"/><path d="M14.8 9.2l-1.6 4.1-4.1 1.6 1.6-4.1 4.1-1.6z"/></g></svg>',
  FKIcon.football:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="12" cy="12" r="8.5"/><path d="M12 8.2l3.4 2.4-1.3 3.9H9.9L8.6 10.6 12 8.2z"/><path d="M12 8.2V3.5M15.4 10.6l4.5-1.5M14.1 14.5l2.8 3.8M9.9 14.5l-2.8 3.8M8.6 10.6L4 9.1"/></g></svg>',
  FKIcon.outdoors:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M5 19C5 9 12 4 20 4c0 8-5 15-15 15z"/><path d="M5 19c3-5 7-8.5 11-10.5"/></g></svg>',
  FKIcon.adventure:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M3 19h18M4.5 19L10 8.5l3.5 6 2-3.2L20 19"/></g></svg>',
  FKIcon.sunshine:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="12" cy="12" r="4"/><path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6L7 7M17 17l1.4 1.4M18.4 5.6L17 7M7 17l-1.4 1.4"/></g></svg>',

  // ── PLAY & CRAFT ──
  FKIcon.art:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 3a9 9 0 100 18c1.2 0 2-.9 2-2 0-.6-.2-1-.5-1.4-.3-.4-.5-.8-.5-1.3 0-1.1.9-2 2-2H17a4 4 0 004-4c0-4-4.2-7.3-9-7.3z"/><circle cx="7.6" cy="10.2" r=".4"/><circle cx="10.4" cy="7.2" r=".4"/><circle cx="14.4" cy="7.4" r=".4"/></g></svg>',
  FKIcon.music:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M9 18.5V6l10-2v11.5"/><circle cx="7" cy="18.5" r="2"/><circle cx="17" cy="15.5" r="2"/></g></svg>',
  FKIcon.listen:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M4 14v-1.5a8 8 0 0116 0V14"/><rect x="3" y="13.5" width="3.5" height="6" rx="1.5"/><rect x="17.5" y="13.5" width="3.5" height="6" rx="1.5"/></g></svg>',
  FKIcon.photo:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="3" y="7" width="18" height="13" rx="2.5"/><path d="M8 7l1.2-2.4h5.6L16 7"/><circle cx="12" cy="13" r="3.5"/></g></svg>',
  FKIcon.game:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M7 8h10a5 5 0 014.9 5.9l-.6 3a2.6 2.6 0 01-4.4 1.3L15 16.5H9l-1.9 1.7a2.6 2.6 0 01-4.4-1.3l-.6-3A5 5 0 017 8z"/><path d="M8.5 12.2h3M10 10.7v3"/><circle cx="15.6" cy="11.4" r=".4"/><circle cx="17.4" cy="13.2" r=".4"/></g></svg>',
  FKIcon.play:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><rect x="4" y="4" width="16" height="16" rx="3"/><circle cx="9" cy="9" r=".4"/><circle cx="15" cy="9" r=".4"/><circle cx="12" cy="12" r=".4"/><circle cx="9" cy="15" r=".4"/><circle cx="15" cy="15" r=".4"/></g></svg>',
  FKIcon.puzzle:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M10 4h4v1.6a1.8 1.8 0 003.6 0V4H20v6h-1.6a1.8 1.8 0 000 3.6H20V20h-6v-1.6a1.8 1.8 0 00-3.6 0V20H4v-6h1.6a1.8 1.8 0 000-3.6H4V4h6z"/></g></svg>',

  // ── MARKS ──
  FKIcon.favourite:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><path d="M12 3.5l2.5 5.2 5.7.8-4.1 4 1 5.7-5.1-2.7-5.1 2.7 1-5.7-4.1-4 5.7-.8z"/></g></svg>',
  FKIcon.totalFocus:
      '<svg viewBox="0 0 24 24"><g stroke="#000" $_p><circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="4.4"/><circle cx="12" cy="12" r="1"/></g></svg>',
};

/// Human-readable labels, e.g. for the icon picker's accessibility
/// semantics or tooltips.
const Map<FKIcon, String> fkIconLabels = {
  FKIcon.work: 'Work', FKIcon.deepwork: 'Deep work', FKIcon.study: 'Study',
  FKIcon.write: 'Write', FKIcon.school: 'School', FKIcon.create: 'Create',
  FKIcon.journal: 'Journal', FKIcon.read: 'Read', FKIcon.world: 'World',
  FKIcon.thelab: 'The Lab',
  FKIcon.gym: 'Gym', FKIcon.run: 'Run', FKIcon.ride: 'Ride',
  FKIcon.swim: 'Swim', FKIcon.yoga: 'Yoga', FKIcon.health: 'Health',
  FKIcon.sleep: 'Sleep', FKIcon.winddown: 'Wind down',
  FKIcon.morning: 'Morning', FKIcon.evening: 'Evening', FKIcon.quiet: 'Quiet',
  FKIcon.dnd: 'Do not disturb', FKIcon.mindful: 'Mindful',
  FKIcon.deeptime: 'Deep time', FKIcon.timer: 'Timer',
  FKIcon.meals: 'Meals', FKIcon.cook: 'Cook', FKIcon.brew: 'Break',
  FKIcon.movie: 'Movie',
  FKIcon.family: 'Family', FKIcon.home: 'Home', FKIcon.pets: 'Pets',
  FKIcon.garden: 'Garden', FKIcon.celebrate: 'Celebrate', FKIcon.cards: 'Cards',
  FKIcon.travel: 'Travel', FKIcon.explore: 'Explore',
  FKIcon.football: 'Football', FKIcon.outdoors: 'Outdoors',
  FKIcon.adventure: 'Adventure', FKIcon.sunshine: 'Sunshine',
  FKIcon.art: 'Art', FKIcon.music: 'Music', FKIcon.listen: 'Listen',
  FKIcon.photo: 'Photo', FKIcon.game: 'Game', FKIcon.play: 'Play',
  FKIcon.puzzle: 'Puzzle',
  FKIcon.favourite: 'Favourite', FKIcon.totalFocus: 'Total Focus',
};

/// Renders one mode icon at any size/tint.
class FocusIcon extends StatelessWidget {
  final FKIcon icon;
  final double size;
  final Color color;

  const FocusIcon(
    this.icon, {
    super.key,
    this.size = 26,
    this.color = FKIconColors.stroke,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg[icon]!,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: fkIconLabels[icon],
    );
  }
}

/// The selectable tile used on the mode-edit screen —
/// matches the approved gold selected state.
class ModeIconTile extends StatelessWidget {
  final FKIcon icon;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  const ModeIconTile({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FKIconColors.selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? FKIconColors.selectedBorder
                  : FKIconColors.tileBorder,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: FocusIcon(
            icon,
            size: size * 0.41,
            color: selected
                ? FKIconColors.strokeSelected
                : FKIconColors.stroke,
          ),
        ),
      ),
    );
  }
}
