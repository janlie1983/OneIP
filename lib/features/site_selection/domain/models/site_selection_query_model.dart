class SiteSelectionQuery {
  final String industry;
  final double requiredAreaM2;
  final int headcount;
  final String? preferredRegion; // North / Central / South / null = Any
  final List<String> preferredProvinces;
  final double? maxBudgetUsd;
  final List<String> priorityFactors; // infra / labor / logistics / price / tax

  const SiteSelectionQuery({
    required this.industry,
    required this.requiredAreaM2,
    required this.headcount,
    this.preferredRegion,
    this.preferredProvinces = const [],
    this.maxBudgetUsd,
    this.priorityFactors = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'industry': industry,
      'required_area_m2': requiredAreaM2,
      'headcount': headcount,
      'preferred_region': preferredRegion,
      'preferred_provinces': preferredProvinces,
      'max_budget_usd': maxBudgetUsd,
      'priority_factors': priorityFactors,
    };
  }
}
