import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/saved_articles_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/saved_articles_view.dart';

class SavedArticlesPage extends StatelessWidget {
  const SavedArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SavedArticlesCubit>()..fetchSavedArticles(),
      child: const SavedArticlesView(),
    );
  }
}
