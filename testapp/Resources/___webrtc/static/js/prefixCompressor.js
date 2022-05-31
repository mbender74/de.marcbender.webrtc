async function loadLZMAPrefixCompressor(prefixFilename) {
  class PrefixCompressor {
    constructor(prefix, compress, decompress, bytesToIgnore) {
      this.prefix = prefix;
      this.prefixCompressed = compress(prefix);
      this.bytesToIgnore = bytesToIgnore;
      this.baseCompress = compress;
      this.baseDecompress = decompress;
    }

    compress(str) {
      const c = this.baseCompress(this.prefix + str);
      for (var i = this.bytesToIgnore;
           i < this.prefixCompressed.length
             && this.prefixCompressed[i] == c[i];
           i++) { }
      const omittedBytes = this.prefixCompressed.length - i;
      const res = c.subarray(i - 1);
      res[0] = omittedBytes;
      return res;
    }

    decompress(arr) {
      const omittedBytes = arr[0];
      const prefixBytes = this.prefixCompressed.length-omittedBytes;
      const c = new Uint8Array(prefixBytes + arr.length-1);
      c.set(this.prefixCompressed.subarray(0, prefixBytes));
      c.set(arr.subarray(1), prefixBytes);
      const d = this.baseDecompress(c);
      return d.substring(this.prefix.length);
    }
  }
  async function loadDictionary() {
    const response = await fetch(prefixFilename);
    return await response.text();
  }
  const prefix = await loadDictionary();

  return new PrefixCompressor(prefix, str => {
    const res = new Uint8Array(LZMA.compress(str, 9));
    // Clear uncompressed size as it will be invalid.
    for (var i = 5; i < 13; i++) res[i] = 255;
    return res;
  }, arr => {
    return LZMA.decompress(arr).toString();
  }, 12);
}
