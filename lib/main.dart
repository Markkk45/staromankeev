// ═══════════════════════════════════════════════════════════════════════════
// СТАРОМАНКЕЕВСКИЙ ЯЗЫК — Интерактивный словарь и генератор редукции
// Flutter Application • v1.0.0
//
// Агглютинативная фонетика с финно-угорскими/тюркскими корнями
// и славянским субстратом. Базовые суффиксы: -аль, -маль, -таль,
// -идаль, -окт, -тарт, -талт.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Точка входа ────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF121214),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const StaromankeevApp());
}

// ─── Цветовая палитра ───────────────────────────────────────────────────

abstract final class C {
  static const bg        = Color(0xFF121214);
  static const surface   = Color(0xFF1A1A1E);
  static const surfaceHi = Color(0xFF242428);
  static const gold      = Color(0xFFD4AF37);
  static const goldLt    = Color(0xFFE8C95A);
  static const goldDk    = Color(0xFFB8941F);
  static const txt       = Color(0xFFF0E6D2);
  static const txtSec    = Color(0xFF9E9E9E);
  static const txtMut    = Color(0xFF5A5A5E);
  static const divider   = Color(0xFF2A2A2E);
  static const border    = Color(0xFF333338);
}

// ─── Модели данных ──────────────────────────────────────────────────────

class WordEntry {
  final String word;
  final String transcription;
  final String translation;
  final String reduced;
  final String category;
  final bool isException;

  const WordEntry({
    required this.word,
    required this.transcription,
    required this.translation,
    required this.reduced,
    required this.category,
    this.isException = false,
  });
}

class AlphabetEntry {
  final String cyrillic;
  final String smkName;
  final String phoneme;
  final String glyphNote;

  const AlphabetEntry({
    required this.cyrillic,
    required this.smkName,
    required this.phoneme,
    this.glyphNote = '',
  });
}

// ─── Корневой виджет ────────────────────────────────────────────────────

class StaromankeevApp extends StatelessWidget {
  const StaromankeevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Староманкеевский язык',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: C.bg,
        colorScheme: const ColorScheme.dark(
          surface: C.bg,
          primary: C.gold,
          secondary: C.goldLt,
          onSurface: C.txt,
          onPrimary: C.bg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: C.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: C.gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: C.gold,
          unselectedLabelColor: C.txtMut,
          indicatorColor: C.gold,
          indicatorSize: TabBarIndicatorSize.label,
          dividerHeight: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: C.surface,
          hintStyle: const TextStyle(color: C.txtMut, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: C.gold, width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Главный экран с вкладками ──────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✦ ', style: TextStyle(fontSize: 14, color: C.goldDk)),
            Text('СТАРОМАНКЕЕВСКИЙ'),
            Text(' ✦', style: TextStyle(fontSize: 14, color: C.goldDk)),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded, size: 20), text: 'Словарь'),
            Tab(
                icon: Icon(Icons.auto_fix_high_rounded, size: 20),
                text: 'Сокращатель'),
            Tab(
                icon: Icon(Icons.translate_rounded, size: 20),
                text: 'Алфавит'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          DictionaryTab(),
          ReducerTab(),
          AlphabetTab(),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  ВКЛАДКА 1 — СЛОВАРЬ
// ═════════════════════════════════════════════════════════════════════════

class DictionaryTab extends StatefulWidget {
  const DictionaryTab({super.key});

  @override
  State<DictionaryTab> createState() => _DictionaryTabState();
}

class _DictionaryTabState extends State<DictionaryTab>
    with AutomaticKeepAliveClientMixin {
  final _search = TextEditingController();
  String _cat = 'все';
  List<WordEntry> _filtered = [];

  static const _cats = [
    'все',
    'семья',
    'приветствия',
    'природа',
    'быт',
    'металлы',
    'действия',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(kDictionary);
    _search.addListener(_filter);
  }

  void _filter() {
    final q = _search.text.toLowerCase().trim();
    setState(() {
      _filtered = kDictionary.where((e) {
        if (_cat != 'все' && e.category != _cat) return false;
        if (q.isEmpty) return true;
        return e.word.toLowerCase().contains(q) ||
            e.transcription.toLowerCase().contains(q) ||
            e.translation.toLowerCase().contains(q) ||
            e.reduced.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _pickCat(String c) {
    _cat = c;
    _filter();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Поисковая строка
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            style: const TextStyle(color: C.txt, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Поиск по слову, переводу, транскрипции…',
              prefixIcon: const Icon(Icons.search_rounded, color: C.txtMut),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _search,
                builder: (_, v, __) => v.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: C.txtSec),
                        onPressed: () {
                          _search.clear();
                        },
                      ),
              ),
            ),
          ),
        ),

        // Категории
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _cats[i];
              final on = c == _cat;
              return GestureDetector(
                onTap: () => _pickCat(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: on ? C.gold.withAlpha(38) : C.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: on ? C.gold : C.border,
                      width: on ? 1.0 : 0.5,
                    ),
                  ),
                  child: Text(
                    c[0].toUpperCase() + c.substring(1),
                    style: TextStyle(
                      color: on ? C.gold : C.txtSec,
                      fontSize: 13,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // Счётчик
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_filtered.length} ${_plu(_filtered.length)}',
              style: const TextStyle(color: C.txtMut, fontSize: 12),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Список карточек
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56, color: C.txtMut.withAlpha(77)),
                      const SizedBox(height: 12),
                      const Text('Ничего не найдено',
                          style: TextStyle(color: C.txtMut, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _WordCard(entry: _filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  String _plu(int n) {
    final m = n % 10;
    final h = n % 100;
    if (m == 1 && h != 11) return 'слово';
    if ([2, 3, 4].contains(m) && ![12, 13, 14].contains(h)) return 'слова';
    return 'слов';
  }
}

// ─── Виджет: Карточка слова ─────────────────────────────────────────────

class _WordCard extends StatefulWidget {
  final WordEntry entry;
  const _WordCard({required this.entry});

  @override
  State<_WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<_WordCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _open ? C.gold.withAlpha(102) : C.border,
            width: _open ? 1.0 : 0.5,
          ),
          boxShadow: _open
              ? [
                  BoxShadow(
                      color: C.gold.withAlpha(15),
                      blurRadius: 20,
                      spreadRadius: 1)
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.word,
                          style: const TextStyle(
                              color: C.txt,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 4),
                      Text('[${e.transcription}]',
                          style: TextStyle(
                              color: C.gold.withAlpha(178),
                              fontSize: 13,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: C.gold.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(e.translation,
                      style: const TextStyle(
                          color: C.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            // Раскрывающиеся детали
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _details(e),
              crossFadeState:
                  _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _details(WordEntry e) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const Divider(color: C.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(icon: Icons.label_outline_rounded, text: e.category),
              if (e.isException) ...[
                const SizedBox(width: 8),
                _Pill(
                    icon: Icons.star_rounded,
                    text: 'исключение',
                    color: Colors.orange),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.surfaceHi,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.compress_rounded, size: 16, color: C.goldDk),
                const SizedBox(width: 8),
                const Text('Сокр.: ',
                    style: TextStyle(color: C.txtMut, fontSize: 13)),
                Expanded(
                  child: Text(e.reduced,
                      style: const TextStyle(
                          color: C.goldLt,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: e.reduced));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Скопировано!'),
                      backgroundColor: C.surfaceHi,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ));
                  },
                  child: const Icon(Icons.copy_rounded,
                      size: 16, color: C.txtMut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Виджет-пилюля ─────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Pill(
      {required this.icon, required this.text, this.color = C.txtMut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  ВКЛАДКА 2 — СОКРАЩАТЕЛЬ СЛОВ
// ═════════════════════════════════════════════════════════════════════════

class ReducerTab extends StatefulWidget {
  const ReducerTab({super.key});

  @override
  State<ReducerTab> createState() => _ReducerTabState();
}

class _ReducerTabState extends State<ReducerTab>
    with SingleTickerProviderStateMixin {
  final _input = TextEditingController();
  String? _result;
  List<String>? _syllables;
  bool _show = false;
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  void _reduce() {
    final w = _input.text.trim();
    if (w.isEmpty) return;

    final syl = Reducer.splitSyllables(w);
    final res = Reducer.reduce(w);

    setState(() {
      _syllables = syl;
      _result = res;
      _show = true;
    });
    _anim.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _input.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок
          _headerBox(
            icon: Icons.auto_fix_high_rounded,
            title: 'Генератор редукции',
            subtitle:
                'Введите полное слово на староманкеевском.\n'
                'Алгоритм удалит центральные слоги по правилам языка.',
          ),
          const SizedBox(height: 24),

          // Ввод
          TextField(
            controller: _input,
            style: const TextStyle(color: C.txt, fontSize: 18),
            decoration: const InputDecoration(
              hintText: 'напр. пэолтколаль',
              prefixIcon: Icon(Icons.edit_rounded, color: C.txtMut),
            ),
            onSubmitted: (_) => _reduce(),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),

          // Кнопка
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _reduce,
              style: ElevatedButton.styleFrom(
                backgroundColor: C.gold,
                foregroundColor: C.bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compress_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Сократить'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Результат
          if (_show && _result != null)
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _resultCard(),
              ),
            ),

          // Примеры
          const SizedBox(height: 20),
          _examplesSection(),

          // Правила
          const SizedBox(height: 16),
          _rulesSection(),
        ],
      ),
    );
  }

  Widget _resultCard() {
    final syl = _syllables!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.gold.withAlpha(102)),
        boxShadow: [
          BoxShadow(
              color: C.gold.withAlpha(13), blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          // Слоговая разбивка
          if (syl.length > 1) ...[
            const Text('Слоговая разбивка:',
                style: TextStyle(color: C.txtMut, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: syl.asMap().entries.map((e) {
                final rm = _isRemoved(e.key, syl.length);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: rm
                        ? Colors.red.withAlpha(38)
                        : C.gold.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: rm
                            ? Colors.red.withAlpha(76)
                            : C.gold.withAlpha(76)),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: rm ? Colors.red.shade300 : C.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: rm ? TextDecoration.lineThrough : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Divider(color: C.divider.withAlpha(128)),
            const SizedBox(height: 16),
          ],

          // Сокращённая форма
          const Text('Сокращённая форма:',
              style: TextStyle(color: C.txtMut, fontSize: 12)),
          const SizedBox(height: 8),
          SelectableText(
            _result!,
            style: const TextStyle(
              color: C.gold,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _result!));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Скопировано в буфер обмена'),
                backgroundColor: C.surfaceHi,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ));
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Копировать'),
            style: TextButton.styleFrom(foregroundColor: C.txtSec),
          ),
        ],
      ),
    );
  }

  bool _isRemoved(int i, int total) {
    // Check dictionary exception first
    final w = _input.text.trim().toLowerCase();
    if (Reducer.isExceptionWord(w)) return false;
    if (total <= 2) return false;
    if (total == 3) return i == 1;
    final mid = (total - 2) ~/ 2;
    return i >= mid && i < mid + 2;
  }

  Widget _examplesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: C.goldDk, size: 16),
              SizedBox(width: 8),
              Text('Примеры',
                  style: TextStyle(
                      color: C.goldDk,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          _exRow('пэолтколаль', 'пэолталь', 'стандарт'),
          _exRow('приветтарт', 'приветтарт', 'исключ.'),
          _exRow('сортамталт', 'сорталт', 'стандарт'),
          _exRow('златотарт', 'златотарт', 'исключ.'),
        ],
      ),
    );
  }

  Widget _exRow(String from, String to, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(from,
                style: const TextStyle(color: C.txtSec, fontSize: 12)),
          ),
          const Icon(Icons.arrow_forward_rounded,
              size: 12, color: C.txtMut),
          const SizedBox(width: 6),
          Text(to,
              style: const TextStyle(
                  color: C.goldLt,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: C.txtMut.withAlpha(25),
              borderRadius: BorderRadius.circular(4),
            ),
            child:
                Text(tag, style: const TextStyle(color: C.txtMut, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _rulesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: C.txtMut, size: 16),
              SizedBox(width: 8),
              Text('Правила редукции',
                  style: TextStyle(
                      color: C.txtSec,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Удаляются 2 центральных слога (≥4 слогов)\n'
            '• При 3 слогах — удаляется средний\n'
            '• Слова с ≤2 слогами не сокращаются\n'
            '• Приветствия: русская основа + суффикс -тарт\n'
            '• Металлы: славянский корень + суффикс -тарт',
            style: TextStyle(color: C.txtMut, fontSize: 12, height: 1.7),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  ВКЛАДКА 3 — АЛФАВИТ
// ═════════════════════════════════════════════════════════════════════════

class AlphabetTab extends StatelessWidget {
  const AlphabetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Заголовок
        SliverToBoxAdapter(
          child: _headerBox(
            icon: Icons.translate_rounded,
            title: 'Староманкеевская письменность',
            subtitle:
                'Угловатые глифы с элементами рунических\n'
                'и тюркских письменных традиций.\n'
                'Рукописные формы — по оригинальному манускрипту.',
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          ),
        ),

        // Сетка алфавита
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _AlphabetCard(entry: kAlphabet[i]),
              childCount: kAlphabet.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
          ),
        ),

        // Суффиксы
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Базовые суффиксы',
                    style: TextStyle(
                        color: C.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _SuffixChip('-аль', 'имена, мягкие основы'),
                    _SuffixChip('-маль', 'материнские, женские'),
                    _SuffixChip('-таль', 'абстрактные'),
                    _SuffixChip('-идаль', 'природные явления'),
                    _SuffixChip('-окт', 'стихии, силы'),
                    _SuffixChip('-тарт', 'заимствования, металлы'),
                    _SuffixChip('-талт', 'предметы, дом, быт'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Фонетические правила
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фонетические особенности',
                    style: TextStyle(
                        color: C.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Text(
                  '• Дифтонги: эо, эа, оа — считаются одним слогом\n'
                  '• Мягкий знак (ь) не образует слог\n'
                  '• Кластеры согласных (лт, нт, лтк) — часть предыдущего слога\n'
                  '• Ударение тоническое, как правило на предпоследнем слоге\n'
                  '• Суффикс определяет семантический класс слова',
                  style: TextStyle(color: C.txtSec, fontSize: 12, height: 1.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Виджет: Карточка буквы ─────────────────────────────────────────────

class _AlphabetCard extends StatelessWidget {
  final AlphabetEntry entry;
  const _AlphabetCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entry.cyrillic,
              style: const TextStyle(
                fontSize: 26,
                color: C.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entry.smkName,
              style: const TextStyle(
                fontSize: 11,
                color: C.goldLt,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entry.phoneme,
              style: const TextStyle(
                fontSize: 10,
                color: C.txtMut,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: C.txtMut,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(entry.cyrillic,
                style: const TextStyle(
                    fontSize: 48, color: C.gold, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(entry.smkName,
                style: const TextStyle(
                    fontSize: 20,
                    color: C.goldLt,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Фонема: ${entry.phoneme}',
                style: const TextStyle(color: C.txtSec, fontSize: 16)),
            if (entry.glyphNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.surfaceHi,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(entry.glyphNote,
                    style: const TextStyle(
                        color: C.txtSec, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Виджет: Суффикс-чип ────────────────────────────────────────────────

class _SuffixChip extends StatelessWidget {
  final String text;
  final String hint;
  const _SuffixChip(this.text, this.hint);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: C.gold.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.gold.withAlpha(76)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: C.goldLt, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Общий виджет: Заголовочный блок ────────────────────────────────────

Widget _headerBox({
  required IconData icon,
  required String title,
  required String subtitle,
  EdgeInsetsGeometry margin = const EdgeInsets.all(16),
}) {
  return Container(
    margin: margin,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [C.gold.withAlpha(20), C.surface],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.gold.withAlpha(51)),
    ),
    child: Column(
      children: [
        Icon(icon, color: C.gold, size: 32),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                color: C.gold,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: C.txtSec, fontSize: 13, height: 1.5)),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════
//  ЛОГИКА РЕДУКЦИИ
// ═════════════════════════════════════════════════════════════════════════

abstract final class Reducer {
  static const _vowels = 'аеёиоуыэюя';

  /// Исключения: приветствия
  static const _greetEx = {
    'пэрэлильтветарт': 'приветтарт',
    'здравалтветокт': 'здравтарт',
    'добралтутроталт': 'добруталт',
  };

  /// Исключения: металлы
  static const _metalEx = {
    'золоталтарт': 'златотарт',
    'серебралтарт': 'серебротарт',
    'медьталтарт': 'медьтарт',
    'железоталтарт': 'железотарт',
    'бронзалтарт': 'бронзотарт',
  };

  static bool isExceptionWord(String w) {
    final lw = w.toLowerCase();
    return _greetEx.containsKey(lw) || _metalEx.containsKey(lw);
  }

  /// Основная функция сокращения
  static String reduce(String word) {
    final lw = word.toLowerCase();

    // 1. Поиск в предзагруженном словаре
    for (final e in kDictionary) {
      if (e.word.toLowerCase() == lw) return e.reduced;
    }

    // 2. Таблица исключений
    if (_greetEx.containsKey(lw)) return _greetEx[lw]!;
    if (_metalEx.containsKey(lw)) return _metalEx[lw]!;

    // 3. Стандартная редукция
    final syl = splitSyllables(lw);
    if (syl.length <= 2) return word;

    if (syl.length == 3) {
      return syl.first + syl.last;
    }

    // Убрать 2 средних слога
    final mid = (syl.length - 2) ~/ 2;
    final buf = StringBuffer();
    for (int i = 0; i < syl.length; i++) {
      if (i < mid || i >= mid + 2) buf.write(syl[i]);
    }
    return buf.toString();
  }

  /// Разбивка на слоги по правилам староманкеевской фонетики
  /// — Смежные гласные (дифтонги: эо, эа, оа) = одно ядро
  /// — Кластер согласных делится: все кроме последней → предыдущий слог
  static List<String> splitSyllables(String word) {
    if (word.isEmpty) return [word];
    final lw = word.toLowerCase();

    // Найти ядра гласных (дифтонги = одно ядро)
    final nuclei = <List<int>>[]; // [startPos, endPos] включительно
    int i = 0;
    while (i < lw.length) {
      if (_vowels.contains(lw[i])) {
        final start = i;
        while (i < lw.length && _vowels.contains(lw[i])) {
          i++;
        }
        nuclei.add([start, i - 1]);
      } else {
        i++;
      }
    }

    if (nuclei.isEmpty) return [word];
    if (nuclei.length == 1) return [word];

    // Разбить по границам между ядрами
    final syllables = <String>[];
    int start = 0;

    for (int k = 0; k < nuclei.length - 1; k++) {
      final nucEnd = nuclei[k][1];
      final nextNucStart = nuclei[k + 1][0];
      final consonants = nextNucStart - nucEnd - 1;

      int splitAt;
      if (consonants <= 1) {
        // Единственный согласный → следующий слог
        splitAt = nucEnd + 1;
      } else {
        // Кластер: все кроме последней согласной → текущий слог
        splitAt = nextNucStart - 1;
      }

      syllables.add(word.substring(start, splitAt));
      start = splitAt;
    }
    syllables.add(word.substring(start));

    return syllables;
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  ДАННЫЕ: СЛОВАРЬ
// ═════════════════════════════════════════════════════════════════════════

const List<WordEntry> kDictionary = [
  // ──── Семья ────────────────────────────────────────────────────────
  WordEntry(
    word: 'пэзальпэаль',
    transcription: 'pɛːzálʲpɛːálʲ',
    translation: 'папа',
    reduced: 'пэзаль',
    category: 'семья',
  ),
  WordEntry(
    word: 'эмальзмаль',
    transcription: 'ɛːmálʲzmálʲ',
    translation: 'мама',
    reduced: 'эмаль',
    category: 'семья',
  ),
  WordEntry(
    word: 'сэнталтокт',
    transcription: 'sɛntáltókt',
    translation: 'сын',
    reduced: 'сэнокт',
    category: 'семья',
  ),
  WordEntry(
    word: 'дочальталт',
    transcription: 'dočálʲtált',
    translation: 'дочь',
    reduced: 'дочталт',
    category: 'семья',
  ),
  WordEntry(
    word: 'брателтмаль',
    transcription: 'brátɛltmálʲ',
    translation: 'брат',
    reduced: 'братмаль',
    category: 'семья',
  ),
  WordEntry(
    word: 'сэстральидаль',
    transcription: 'sɛstrálʲidálʲ',
    translation: 'сестра',
    reduced: 'сэстраль',
    category: 'семья',
  ),
  WordEntry(
    word: 'дэдалтокт',
    transcription: 'dɛdáltókt',
    translation: 'дед',
    reduced: 'дэдокт',
    category: 'семья',
  ),
  WordEntry(
    word: 'бабалтмаль',
    transcription: 'babáltmálʲ',
    translation: 'бабушка',
    reduced: 'бабмаль',
    category: 'семья',
  ),

  // ──── Приветствия ──────────────────────────────────────────────────
  WordEntry(
    word: 'пэолтколаль',
    transcription: 'pɛːóltkolálʲ',
    translation: 'пока',
    reduced: 'пэолталь',
    category: 'приветствия',
  ),
  WordEntry(
    word: 'пэрэлильтветарт',
    transcription: 'pɛːrɛlílʲtvɛtárt',
    translation: 'привет',
    reduced: 'приветтарт',
    category: 'приветствия',
    isException: true,
  ),
  WordEntry(
    word: 'здравалтветокт',
    transcription: 'zdrávaltvetókt',
    translation: 'здравствуй',
    reduced: 'здравтарт',
    category: 'приветствия',
    isException: true,
  ),
  WordEntry(
    word: 'добралтутроталт',
    transcription: 'dóbraltutrótalt',
    translation: 'доброе утро',
    reduced: 'добруталт',
    category: 'приветствия',
  ),
  WordEntry(
    word: 'спокалтнойталт',
    transcription: 'spokáltnójtált',
    translation: 'спокойной ночи',
    reduced: 'спокталт',
    category: 'приветствия',
  ),

  // ──── Природа ─────────────────────────────────────────────────────
  WordEntry(
    word: 'солтаид',
    transcription: 'soltáid',
    translation: 'солнце',
    reduced: 'солтаид',
    category: 'природа',
  ),
  WordEntry(
    word: 'светвет',
    transcription: 'svɛ́tvɛːt',
    translation: 'свет',
    reduced: 'светвет',
    category: 'природа',
  ),
  WordEntry(
    word: 'водалтмаль',
    transcription: 'vodáltmálʲ',
    translation: 'вода',
    reduced: 'водаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'огнетокт',
    transcription: 'ognɛ́tókt',
    translation: 'огонь',
    reduced: 'огнокт',
    category: 'природа',
  ),
  WordEntry(
    word: 'зеталтмаль',
    transcription: 'zɛtáltmálʲ',
    translation: 'земля',
    reduced: 'земаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'нэбомаль',
    transcription: 'nɛbómálʲ',
    translation: 'небо',
    reduced: 'нэбаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'вэтэрмалталт',
    transcription: 'vɛtɛ́rmaltált',
    translation: 'ветер',
    reduced: 'вэтталт',
    category: 'природа',
  ),
  WordEntry(
    word: 'рэкалтмаль',
    transcription: 'rɛkáltmálʲ',
    translation: 'река',
    reduced: 'рэкаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'горалтокт',
    transcription: 'goráltokt',
    translation: 'гора',
    reduced: 'горокт',
    category: 'природа',
  ),
  WordEntry(
    word: 'звэздалтидаль',
    transcription: 'zvɛzdáltidálʲ',
    translation: 'звезда',
    reduced: 'звэздаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'лунатарталт',
    transcription: 'lunátartált',
    translation: 'луна',
    reduced: 'лунталт',
    category: 'природа',
  ),
  WordEntry(
    word: 'дэрэвоталт',
    transcription: 'dɛrɛvótált',
    translation: 'дерево',
    reduced: 'дэрталт',
    category: 'природа',
  ),
  WordEntry(
    word: 'камэнтидаль',
    transcription: 'kamɛ́ntidálʲ',
    translation: 'камень',
    reduced: 'камаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'пэтицалтмаль',
    transcription: 'pɛtícaltmálʲ',
    translation: 'птица',
    reduced: 'пэтмаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'рыбалидаль',
    transcription: 'rɨbálidálʲ',
    translation: 'рыба',
    reduced: 'рыбаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'лесалтокт',
    transcription: 'lɛsáltókt',
    translation: 'лес',
    reduced: 'лесокт',
    category: 'природа',
  ),
  WordEntry(
    word: 'цвэталтмаль',
    transcription: 'tsvɛtáltmálʲ',
    translation: 'цветок',
    reduced: 'цвэтмаль',
    category: 'природа',
  ),
  WordEntry(
    word: 'снэгалтталт',
    transcription: 'snɛgálttált',
    translation: 'снег',
    reduced: 'снэгталт',
    category: 'природа',
  ),
  WordEntry(
    word: 'дождалтидаль',
    transcription: 'dóʒdaltidálʲ',
    translation: 'дождь',
    reduced: 'дождаль',
    category: 'природа',
  ),

  // ──── Быт ─────────────────────────────────────────────────────────
  WordEntry(
    word: 'сортамталт',
    transcription: 'sortámtált',
    translation: 'дом',
    reduced: 'сорталт',
    category: 'быт',
  ),
  WordEntry(
    word: 'хлебмалталт',
    transcription: 'xlɛ́bmaltált',
    translation: 'хлеб',
    reduced: 'хлебталт',
    category: 'быт',
  ),
  WordEntry(
    word: 'друготаидаль',
    transcription: 'drugotáidálʲ',
    translation: 'друг',
    reduced: 'другаль',
    category: 'быт',
  ),
  WordEntry(
    word: 'сомалтемаль',
    transcription: 'somáltɛmálʲ',
    translation: 'сок',
    reduced: 'сомаль',
    category: 'быт',
  ),
  WordEntry(
    word: 'путьталтокт',
    transcription: 'putʲtáltókt',
    translation: 'путь',
    reduced: 'путокт',
    category: 'быт',
  ),
  WordEntry(
    word: 'кнеталтгаль',
    transcription: 'knɛtáltgálʲ',
    translation: 'книга',
    reduced: 'кнегаль',
    category: 'быт',
  ),
  WordEntry(
    word: 'стололтмаль',
    transcription: 'stolóltmálʲ',
    translation: 'стол',
    reduced: 'столаль',
    category: 'быт',
  ),
  WordEntry(
    word: 'порталтидаль',
    transcription: 'portáltidálʲ',
    translation: 'порт',
    reduced: 'порталь',
    category: 'быт',
  ),
  WordEntry(
    word: 'окноталтмаль',
    transcription: 'oknótaltmálʲ',
    translation: 'окно',
    reduced: 'окномаль',
    category: 'быт',
  ),
  WordEntry(
    word: 'дверталтокт',
    transcription: 'dvɛrtáltókt',
    translation: 'дверь',
    reduced: 'дверокт',
    category: 'быт',
  ),
  WordEntry(
    word: 'ложкалтмаль',
    transcription: 'lóʒkaltmálʲ',
    translation: 'ложка',
    reduced: 'ложмаль',
    category: 'быт',
  ),
  WordEntry(
    word: 'чашалтидаль',
    transcription: 'čášaltidálʲ',
    translation: 'чашка',
    reduced: 'чашаль',
    category: 'быт',
  ),

  // ──── Металлы (исключения) ────────────────────────────────────────
  WordEntry(
    word: 'золоталтарт',
    transcription: 'zolotáltárt',
    translation: 'золото',
    reduced: 'златотарт',
    category: 'металлы',
    isException: true,
  ),
  WordEntry(
    word: 'серебралтарт',
    transcription: 'sɛrɛbráltárt',
    translation: 'серебро',
    reduced: 'серебротарт',
    category: 'металлы',
    isException: true,
  ),
  WordEntry(
    word: 'медьталтарт',
    transcription: 'mɛdʲtáltárt',
    translation: 'медь',
    reduced: 'медьтарт',
    category: 'металлы',
    isException: true,
  ),
  WordEntry(
    word: 'железоталтарт',
    transcription: 'ʒɛlɛzotáltárt',
    translation: 'железо',
    reduced: 'железотарт',
    category: 'металлы',
    isException: true,
  ),
  WordEntry(
    word: 'бронзалтарт',
    transcription: 'bronzáltárt',
    translation: 'бронза',
    reduced: 'бронзотарт',
    category: 'металлы',
    isException: true,
  ),

  // ──── Действия ────────────────────────────────────────────────────
  WordEntry(
    word: 'идталтокт',
    transcription: 'idtáltókt',
    translation: 'идти',
    reduced: 'идокт',
    category: 'действия',
  ),
  WordEntry(
    word: 'говоралтмаль',
    transcription: 'govoráltmálʲ',
    translation: 'говорить',
    reduced: 'говмаль',
    category: 'действия',
  ),
  WordEntry(
    word: 'видэлталтокт',
    transcription: 'vidɛltáltókt',
    translation: 'видеть',
    reduced: 'видокт',
    category: 'действия',
  ),
  WordEntry(
    word: 'слышалтидаль',
    transcription: 'slɨšáltidálʲ',
    translation: 'слышать',
    reduced: 'слышаль',
    category: 'действия',
  ),
  WordEntry(
    word: 'есталтмаль',
    transcription: 'jɛstáltmálʲ',
    translation: 'есть (кушать)',
    reduced: 'есмаль',
    category: 'действия',
  ),
  WordEntry(
    word: 'питалтокт',
    transcription: 'pitáltókt',
    translation: 'пить',
    reduced: 'питокт',
    category: 'действия',
  ),
  WordEntry(
    word: 'писалтмаль',
    transcription: 'pisáltmálʲ',
    translation: 'писать',
    reduced: 'писмаль',
    category: 'действия',
  ),
  WordEntry(
    word: 'читалтидаль',
    transcription: 'čitáltidálʲ',
    translation: 'читать',
    reduced: 'читаль',
    category: 'действия',
  ),
  WordEntry(
    word: 'бежалтокт',
    transcription: 'bɛʒáltókt',
    translation: 'бежать',
    reduced: 'бежокт',
    category: 'действия',
  ),
  WordEntry(
    word: 'спалтидаль',
    transcription: 'spáltidálʲ',
    translation: 'спать',
    reduced: 'спаль',
    category: 'действия',
  ),
];

// ═════════════════════════════════════════════════════════════════════════
//  ДАННЫЕ: АЛФАВИТ (по рукописному манускрипту)
// ═════════════════════════════════════════════════════════════════════════

const List<AlphabetEntry> kAlphabet = [
  AlphabetEntry(
    cyrillic: 'А',
    smkName: 'Аталь',
    phoneme: '/a/',
    glyphNote: 'Угловатый глиф — две наклонных линии с перекладиной. '
        'Напоминает руническую форму ᚨ.',
  ),
  AlphabetEntry(
    cyrillic: 'Б',
    smkName: 'Бэмаль',
    phoneme: '/b/',
    glyphNote: 'Вертикаль с двумя горизонтальными засечками справа. '
        'Из манускрипта: напоминает перевёрнутый крюк.',
  ),
  AlphabetEntry(
    cyrillic: 'В',
    smkName: 'Вэталт',
    phoneme: '/v/',
    glyphNote: 'Волнистая вертикаль — символ ветра в рукописи.',
  ),
  AlphabetEntry(
    cyrillic: 'Г',
    smkName: 'Гэокт',
    phoneme: '/g/',
    glyphNote: 'Угол, открытый вправо. Тюркское влияние.',
  ),
  AlphabetEntry(
    cyrillic: 'Д',
    smkName: 'Дэмаль',
    phoneme: '/d/',
    glyphNote: 'Треугольник с основанием внизу — символ дома.',
  ),
  AlphabetEntry(
    cyrillic: 'Е',
    smkName: 'Этидаль',
    phoneme: '/jɛ/',
    glyphNote: 'Три горизонтальных штриха на вертикали. '
        'В манускрипте — отличается от Э направлением.',
  ),
  AlphabetEntry(
    cyrillic: 'Ё',
    smkName: 'Ёталт',
    phoneme: '/jɔ/',
    glyphNote: 'Как Е, но с двумя точками наверху.',
  ),
  AlphabetEntry(
    cyrillic: 'Ж',
    smkName: 'Жэмаль',
    phoneme: '/ʒ/',
    glyphNote: 'Звезда с шестью лучами — символ жизни.',
  ),
  AlphabetEntry(
    cyrillic: 'З',
    smkName: 'Зэталт',
    phoneme: '/z/',
    glyphNote: 'Зигзаг из трёх отрезков — молния.',
  ),
  AlphabetEntry(
    cyrillic: 'И',
    smkName: 'Идаль',
    phoneme: '/i/',
    glyphNote: 'Одна вертикальная черта — простейший глиф.',
  ),
  AlphabetEntry(
    cyrillic: 'Й',
    smkName: 'Йокт',
    phoneme: '/j/',
    glyphNote: 'Вертикаль с тильдой наверху — краткий звук.',
  ),
  AlphabetEntry(
    cyrillic: 'К',
    smkName: 'Кэмаль',
    phoneme: '/k/',
    glyphNote: 'Угол, открытый влево — зеркальное Г.',
  ),
  AlphabetEntry(
    cyrillic: 'Л',
    smkName: 'Лэталт',
    phoneme: '/l/',
    glyphNote: 'Наклонная с горизонтальной засечкой внизу.',
  ),
  AlphabetEntry(
    cyrillic: 'М',
    smkName: 'Мэмаль',
    phoneme: '/m/',
    glyphNote: 'Двойная вертикаль с V-образным соединением наверху. '
        'В манускрипте рядом с символом СТ.',
  ),
  AlphabetEntry(
    cyrillic: 'Н',
    smkName: 'Нэокт',
    phoneme: '/n/',
    glyphNote: 'Две вертикали, соединённые перекладиной.',
  ),
  AlphabetEntry(
    cyrillic: 'О',
    smkName: 'Оталт',
    phoneme: '/o/',
    glyphNote: 'Овал — единственный округлый глиф в системе. '
        'В манускрипте часть дифтонгов эо, оа.',
  ),
  AlphabetEntry(
    cyrillic: 'П',
    smkName: 'Пэмаль',
    phoneme: '/p/',
    glyphNote: 'Ворота — две вертикали с горизонтальной перекладиной наверху.',
  ),
  AlphabetEntry(
    cyrillic: 'Р',
    smkName: 'Рэталт',
    phoneme: '/r/',
    glyphNote: 'Вертикаль с петлёй наверху.',
  ),
  AlphabetEntry(
    cyrillic: 'С',
    smkName: 'Сэмаль',
    phoneme: '/s/',
    glyphNote: 'Полумесяц, открытый вправо. '
        'Из манускрипта: один из базовых глифов.',
  ),
  AlphabetEntry(
    cyrillic: 'Т',
    smkName: 'Тэокт',
    phoneme: '/t/',
    glyphNote: 'Крест — вертикаль с горизонтальной чертой наверху. '
        'В манускрипте украшен засечками.',
  ),
  AlphabetEntry(
    cyrillic: 'У',
    smkName: 'Удаль',
    phoneme: '/u/',
    glyphNote: 'V-образный глиф с хвостом вниз.',
  ),
  AlphabetEntry(
    cyrillic: 'Ф',
    smkName: 'Фэмаль',
    phoneme: '/f/',
    glyphNote: 'Круг на вертикали — редкий звук в языке.',
  ),
  AlphabetEntry(
    cyrillic: 'Х',
    smkName: 'Хэталт',
    phoneme: '/x/',
    glyphNote: 'Перекрещённые линии — X-образный символ.',
  ),
  AlphabetEntry(
    cyrillic: 'Ц',
    smkName: 'Цэмаль',
    phoneme: '/t͡s/',
    glyphNote: 'Угол с крючком внизу справа.',
  ),
  AlphabetEntry(
    cyrillic: 'Ч',
    smkName: 'Чэокт',
    phoneme: '/t͡ʃ/',
    glyphNote: 'Чаша — полукруг, открытый вверх.',
  ),
  AlphabetEntry(
    cyrillic: 'Ш',
    smkName: 'Шэмаль',
    phoneme: '/ʃ/',
    glyphNote: 'Три вертикальных штриха с общим основанием — гребень.',
  ),
  AlphabetEntry(
    cyrillic: 'Щ',
    smkName: 'Щэталт',
    phoneme: '/ʃː/',
    glyphNote: 'Как Ш, но с дополнительным крючком.',
  ),
  AlphabetEntry(
    cyrillic: 'Ъ',
    smkName: 'Твёрдаль',
    phoneme: '/—/',
    glyphNote: 'Разделительный знак: короткая вертикаль с точкой.',
  ),
  AlphabetEntry(
    cyrillic: 'Ы',
    smkName: 'Ыкталт',
    phoneme: '/ɨ/',
    glyphNote: 'Двойной штрих — «глубокий» гласный.',
  ),
  AlphabetEntry(
    cyrillic: 'Ь',
    smkName: 'Мягкаль',
    phoneme: '/ʲ/',
    glyphNote: 'Маленький крючок, приписываемый к предыдущему глифу.',
  ),
  AlphabetEntry(
    cyrillic: 'Э',
    smkName: 'Этмаль',
    phoneme: '/ɛ/',
    glyphNote: 'Зеркальная Е — штрихи направлены влево. '
        'Самый частый гласный в языке.',
  ),
  AlphabetEntry(
    cyrillic: 'Ю',
    smkName: 'Юталт',
    phoneme: '/ju/',
    glyphNote: 'Комбинация И + О (лигатура).',
  ),
  AlphabetEntry(
    cyrillic: 'Я',
    smkName: 'Яокт',
    phoneme: '/ja/',
    glyphNote: 'Зеркальная Р — петля слева.',
  ),
];
