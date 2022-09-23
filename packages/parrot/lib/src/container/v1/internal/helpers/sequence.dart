class Int32SequenceGenerator {
  Int32SequenceGenerator();

  int _current = 0;

  int next() {
    _current = (_current + 1) % 0xffffffff;
    return _current;
  }
}
