class ListingFilter {
  final String? assetType;
  final String? region;
  final String? province;
  final double? minAreaM2;
  final double? maxAreaM2;
  final double? maxPriceUsd;
  final String sortBy;
  final String? searchQuery;

  const ListingFilter({
    this.assetType,
    this.region,
    this.province,
    this.minAreaM2,
    this.maxAreaM2,
    this.maxPriceUsd,
    this.sortBy = 'featured',
    this.searchQuery,
  });

  ListingFilter copyWith({
    Object? assetType = _sentinel,
    Object? region = _sentinel,
    Object? province = _sentinel,
    Object? minAreaM2 = _sentinel,
    Object? maxAreaM2 = _sentinel,
    Object? maxPriceUsd = _sentinel,
    String? sortBy,
    Object? searchQuery = _sentinel,
  }) {
    return ListingFilter(
      assetType: assetType == _sentinel ? this.assetType : assetType as String?,
      region: region == _sentinel ? this.region : region as String?,
      province: province == _sentinel ? this.province : province as String?,
      minAreaM2: minAreaM2 == _sentinel ? this.minAreaM2 : minAreaM2 as double?,
      maxAreaM2: maxAreaM2 == _sentinel ? this.maxAreaM2 : maxAreaM2 as double?,
      maxPriceUsd:
          maxPriceUsd == _sentinel ? this.maxPriceUsd : maxPriceUsd as double?,
      sortBy: sortBy ?? this.sortBy,
      searchQuery:
          searchQuery == _sentinel ? this.searchQuery : searchQuery as String?,
    );
  }

  bool get hasActiveFilters =>
      assetType != null ||
      region != null ||
      province != null ||
      minAreaM2 != null ||
      maxAreaM2 != null ||
      maxPriceUsd != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

const _sentinel = Object();
