// lib/models/case_retriever_model.dart

class SimilarCase {
  final String citation;
  final String caseName;
  final String summary;
  final String relevance;

  SimilarCase({
    required this.citation,
    required this.caseName,
    required this.summary,
    required this.relevance,
  });

  factory SimilarCase.fromJson(Map<String, dynamic> json) {
    return SimilarCase(
      citation: json['citation'] as String? ?? 'No citation found',
      caseName: json['case_name'] as String? ?? 'Unnamed Case',
      summary: json['summary'] as String? ?? 'No summary available.',
      relevance: json['relevance'] as String? ?? 'No relevance provided.',
    );
  }
}

class CaseRetrieverResponse {
  final String message;
  final List<SimilarCase> similarCases;

  CaseRetrieverResponse({
    required this.message,
    required this.similarCases,
  });

  factory CaseRetrieverResponse.fromJson(Map<String, dynamic> json) {
    var caseList = json['similar_cases'] as List? ?? [];
    List<SimilarCase> cases = caseList.map((i) => SimilarCase.fromJson(i)).toList();

    return CaseRetrieverResponse(
      message: json['message'] as String? ?? 'Cases retrieved.',
      similarCases: cases,
    );
  }
}
