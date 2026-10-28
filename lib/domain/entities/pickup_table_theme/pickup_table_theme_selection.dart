import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_color_overrides.dart';

/// line = outline-only cards (border + solid corner tag).
/// fill = solid-filled cards (fill + inverted corner tag). [style] below is
/// fixed to [fill] on the FlowHub side, but the enum is kept (rather than
/// removed) so the wire format/widgets reusing it don't need a matching
/// structural change — see [PickupTableThemeSelection.style]'s doc comment.
enum PickupTableThemeStyle { line, fill }

/// The named color themes for the Pickup Table Theme feature — each is a
/// complete, independent [PickupTableThemeColors] set (background + every accent
/// color, including the timeout gradient and receipt-scan color), not a
/// light/dark-grouped variant of a shared palette like the superseded
/// 5-background system (light1/light2/dark1/dark2/dark3) this replaced.
/// All themes are dark-toned by design (confirmed decision), so there's no
/// light/dark axis anymore — just pick a named theme. Kept the enum's type
/// name (rather than renaming to e.g. PickupTableThemePalette) to avoid
/// touching the freezed-generated PickupTableThemeState type reference.
/// More names will be added here as their color specs are confirmed (see
/// PickupTableThemeRegistry).
enum PickupTableThemeBackground {
  forestGreen,
  charcoal,
  deepNavy,
  slateBlue,
  theme05,
  theme06,
  starbucks,
  mammoth,
  maga,
  doutor,
  supreme,
}

extension PickupTableThemeBackgroundX on PickupTableThemeBackground {
  String get displayLabel => switch (this) {
        PickupTableThemeBackground.forestGreen => 'Forest Green',
        PickupTableThemeBackground.charcoal => 'Charcoal',
        PickupTableThemeBackground.deepNavy => 'Deep Navy',
        PickupTableThemeBackground.slateBlue => 'Slate Blue',
        PickupTableThemeBackground.theme05 => '#05',
        PickupTableThemeBackground.theme06 => '#06',
        PickupTableThemeBackground.starbucks => 'STARBUCKS',
        PickupTableThemeBackground.mammoth => 'MAMMOTH',
        PickupTableThemeBackground.maga => 'MAGA',
        PickupTableThemeBackground.doutor => 'DOUTOR',
        PickupTableThemeBackground.supreme => 'SUPREME',
      };
}

/// A/B/C comparison knob for the guide slot's dotted border — [standard] is
/// the Figma-spec-derived size (radius = half the border's own stroke
/// width, spacing per spec); [medium] is the original pre-Figma-spec size
/// (kept around for comparison); [large] is a bigger, easier-to-see
/// variant — all three requested purely to compare side by side on a live
/// device, not settled design decisions.
enum PickupTableThemeDotStyle { standard, medium, large }

extension PickupTableThemeDotStyleX on PickupTableThemeDotStyle {
  double get dotRadius => switch (this) {
        PickupTableThemeDotStyle.standard => 0.5,
        PickupTableThemeDotStyle.medium => 1.0,
        PickupTableThemeDotStyle.large => 1.5,
      };
  double get dotSpacing => switch (this) {
        PickupTableThemeDotStyle.standard => 3.0,
        PickupTableThemeDotStyle.medium => 6.0,
        PickupTableThemeDotStyle.large => 9.0,
      };

  String get displayLabel => switch (this) {
        PickupTableThemeDotStyle.standard => 'Standard',
        PickupTableThemeDotStyle.medium => 'Medium',
        PickupTableThemeDotStyle.large => 'Large',
      };
}

/// Which static background image (or rotating set) is shown behind the
/// themed grid — independent of [PickupTableThemeBackground] (that's the
/// named *color* palette; this is purely which bitmap asset(s) get drawn
/// under it). [menuImage]/[techImage] are each a single static image;
/// [loopMenuImages] cycles through [assetPaths] (currently 3) on a timer
/// with a crossfade — see PickupBackgroundImageLoop, the widget that
/// actually drives the rotation/fade, in aio_pickuptable_main.dart's
/// background-rendering branch. Add a new value + path(s) here whenever a
/// new option is needed — nothing else needs a structural change (same
/// `.name`/`firstWhere` wire-format convention as [PickupTableThemeDotStyle]).
///
enum PickupTableThemeBackgroundImage { menuImage, techImage, loopMenuImages }

extension PickupTableThemeBackgroundImageX on PickupTableThemeBackgroundImage {
  /// Always a list, even for the two single-image options — lets the
  /// renderer branch purely on `assetPaths.length > 1` rather than on
  /// which enum value this is.
  List<String> get assetPaths => switch (this) {
        PickupTableThemeBackgroundImage.menuImage => const ['assets/images/menu-image.png'],
        PickupTableThemeBackgroundImage.techImage => const ['assets/images/tech-image.png'],
        PickupTableThemeBackgroundImage.loopMenuImages => const [
            'assets/images/loop-menu-image-1.png',
            'assets/images/loop-menu-image-2.png',
            'assets/images/loop-menu-image-3.png',
          ],
      };

  String get displayLabel => switch (this) {
        PickupTableThemeBackgroundImage.menuImage => 'Menu Image',
        PickupTableThemeBackgroundImage.techImage => 'Tech Image',
        PickupTableThemeBackgroundImage.loopMenuImages => 'Loop Menu Images',
      };
}

/// Selection for the Pickup Table Theme feature — a single design (dotted
/// guide border, translucent guide/highlight backgrounds, real gradients
/// on the timeout/highlight card). Reuses [PickupTableThemeStyle]
/// (line/fill means the same thing here); the background axis is
/// [PickupTableThemeBackground], a named palette rather than a light/dark
/// toggle (every theme here is dark-toned by design).
class PickupTableThemeSelection {
  final PickupTableThemeBackground background;
  final PickupTableThemeStyle style;
  final PickupTableThemeDotStyle dotStyle;
  final PickupTableThemeBackgroundImage backgroundImage;
  // FlowHub's color-palette editor (per-slot fill1/fill2 swatches under
  // the named theme picker) — when present, PickupTableThemeRegistry.
  // resolveSelection() builds the actual PickupTableThemeColors from
  // THESE raw values instead of looking [background] up in its built-in
  // palette table. Null means "use the named theme's stock colors as-is"
  // (e.g. an old FlowHub build that predates the palette editor).
  final PickupTableThemeColorOverrides? colorOverrides;

  const PickupTableThemeSelection({
    required this.background,
    required this.style,
    this.dotStyle = PickupTableThemeDotStyle.standard,
    this.backgroundImage = PickupTableThemeBackgroundImage.menuImage,
    this.colorOverrides,
  });

  factory PickupTableThemeSelection.fromJson(Map<String, dynamic> json) {
    final overridesJson = json['colorOverrides'];
    return PickupTableThemeSelection(
      background: PickupTableThemeBackground.values.firstWhere(
        (e) => e.name == json['background'],
        orElse: () => PickupTableThemeBackground.forestGreen,
      ),
      style: PickupTableThemeStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => PickupTableThemeStyle.fill,
      ),
      dotStyle: PickupTableThemeDotStyle.values.firstWhere(
        (e) => e.name == json['dotStyle'],
        orElse: () => PickupTableThemeDotStyle.standard,
      ),
      backgroundImage: PickupTableThemeBackgroundImage.values.firstWhere(
        (e) => e.name == json['backgroundImage'],
        orElse: () => PickupTableThemeBackgroundImage.menuImage,
      ),
      colorOverrides: overridesJson is Map<String, dynamic>
          ? PickupTableThemeColorOverrides.fromJson(overridesJson)
          : null,
    );
  }
}

extension PickupTableThemeSelectionJson on PickupTableThemeSelection {
  Map<String, dynamic> toJson() => {
        'background': background.name,
        'style': style.name,
        'dotStyle': dotStyle.name,
        'backgroundImage': backgroundImage.name,
        if (colorOverrides != null) 'colorOverrides': colorOverrides!.toJson(),
      };
}
