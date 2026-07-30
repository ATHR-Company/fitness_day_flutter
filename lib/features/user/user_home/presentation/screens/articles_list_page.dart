import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/articles_list_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/articles_list_content.dart';

class ArticlesListPage extends StatelessWidget {
  /// الـ articles دي بتتجاهل — الـ page دلوقتي بتجيب data من API مباشرة.
  /// بس محتفظين بالـ parameter عشان مش نكسر الـ call الموجود في home_page.
  final List<ArticleData> articles;

  const ArticlesListPage({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ArticlesListCubit>()..loadFirstPage(),
      child: const ArticlesListContent(),
    );
  }
}
