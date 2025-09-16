import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for generic Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  /// Get a document by path
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) async {
    try {
      return await _firestore.doc(path).get();
    } catch (e) {
      throw FirestoreException('Failed to get document: $e');
    }
  }

  /// Set document data
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      if (merge) {
        await _firestore.doc(path).set(data, SetOptions(merge: true));
      } else {
        await _firestore.doc(path).set(data);
      }
    } catch (e) {
      throw FirestoreException('Failed to set document: $e');
    }
  }

  /// Update document data
  Future<void> updateDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.doc(path).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update document: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String path) async {
    try {
      await _firestore.doc(path).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete document: $e');
    }
  }

  /// Add document to collection
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      throw FirestoreException('Failed to add document: $e');
    }
  }

  /// Get collection documents
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collectionPath, {
    Query<Map<String, dynamic>>? query,
  }) async {
    try {
      if (query != null) {
        return await query.get();
      } else {
        return await _firestore.collection(collectionPath).get();
      }
    } catch (e) {
      throw FirestoreException('Failed to get collection: $e');
    }
  }

  /// Get collection documents with ordering
  Future<QuerySnapshot<Map<String, dynamic>>> getCollectionWithOrder(
    String collectionPath, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Object? startAfter,
    Object? endBefore,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (startAfter != null) {
        query = query.startAfter([startAfter]);
      }

      if (endBefore != null) {
        query = query.endBefore([endBefore]);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw FirestoreException('Failed to get ordered collection: $e');
    }
  }

  /// Get collection documents with where clause
  Future<QuerySnapshot<Map<String, dynamic>>> getCollectionWhere(
    String collectionPath, {
    required String field,
    required dynamic value,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw FirestoreException('Failed to get collection with where clause: $e');
    }
  }

  /// Get collection documents with multiple where clauses
  Future<QuerySnapshot<Map<String, dynamic>>> getCollectionWhereMultiple(
    String collectionPath, {
    required List<WhereClause> whereClauses,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      for (final whereClause in whereClauses) {
        query = query.where(
          whereClause.field,
          isEqualTo: whereClause.isEqualTo,
          isNotEqualTo: whereClause.isNotEqualTo,
          isLessThan: whereClause.isLessThan,
          isLessThanOrEqualTo: whereClause.isLessThanOrEqualTo,
          isGreaterThan: whereClause.isGreaterThan,
          isGreaterThanOrEqualTo: whereClause.isGreaterThanOrEqualTo,
          arrayContains: whereClause.arrayContains,
          arrayContainsAny: whereClause.arrayContainsAny,
          whereIn: whereClause.whereIn,
          whereNotIn: whereClause.whereNotIn,
          isNull: whereClause.isNull,
        );
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw FirestoreException('Failed to get collection with multiple where clauses: $e');
    }
  }

  /// Stream collection documents
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } catch (e) {
      throw FirestoreException('Failed to stream collection: $e');
    }
  }

  /// Stream document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(String path) {
    try {
      return _firestore.doc(path).snapshots();
    } catch (e) {
      throw FirestoreException('Failed to stream document: $e');
    }
  }

  /// Get subcollection documents
  Future<QuerySnapshot<Map<String, dynamic>>> getSubcollection(
    String parentCollection,
    String parentDocId,
    String subcollection, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(subcollection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw FirestoreException('Failed to get subcollection: $e');
    }
  }

  /// Set subcollection document
  Future<void> setSubcollectionDocument(
    String parentCollection,
    String parentDocId,
    String subcollection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      final docRef = _firestore
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(subcollection)
          .doc(docId);

      if (merge) {
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await docRef.set(data);
      }
    } catch (e) {
      throw FirestoreException('Failed to set subcollection document: $e');
    }
  }

  /// Delete subcollection document
  Future<void> deleteSubcollectionDocument(
    String parentCollection,
    String parentDocId,
    String subcollection,
    String docId,
  ) async {
    try {
      await _firestore
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(subcollection)
          .doc(docId)
          .delete();
    } catch (e) {
      throw FirestoreException('Failed to delete subcollection document: $e');
    }
  }

  /// Batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(
              _firestore.doc(operation.path),
              operation.data!,
              operation.setOptions,
            );
            break;
          case BatchOperationType.update:
            batch.update(_firestore.doc(operation.path), operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(_firestore.doc(operation.path));
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to execute batch write: $e');
    }
  }
}

/// Where clause for Firestore queries
class WhereClause {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  final bool? isNull;

  WhereClause({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });
}

/// Batch operation for Firestore
class BatchOperation {
  final BatchOperationType type;
  final String path;
  final Map<String, dynamic>? data;
  final SetOptions? setOptions;

  BatchOperation({
    required this.type,
    required this.path,
    this.data,
    this.setOptions,
  });
}

/// Batch operation types
enum BatchOperationType {
  set,
  update,
  delete,
}

/// Firestore service exception
class FirestoreException implements Exception {
  final String message;

  FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}