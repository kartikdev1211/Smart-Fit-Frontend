// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fit/screens/wardrobe/add_item_screen.dart';
import 'package:smart_fit/screens/wardrobe/wardrobe_detail_screen.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_bloc.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_event.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_state.dart';
import 'package:smart_fit/models/wardrobe_item.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeScreen = size.width > 900;

    return BlocProvider(
      create: (context) {
        final bloc = WardrobeBloc();
        // Immediately fetch wardrobe items
        bloc.add(FetchWardrobeItemsEvent());
        return bloc;
      },
      child: BlocConsumer<WardrobeBloc, WardrobeState>(
        listener: (context, state) {
          if (state is WardrobeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WardrobeItemAdded) {
            // Automatically refresh wardrobe items when a new item is added
            context.read<WardrobeBloc>().add(FetchWardrobeItemsEvent());
          }
        },
        builder: (context, state) {
          debugPrint("🔍 Wardrobe Screen - Current State: $state");
          debugPrint("🔍 Wardrobe Screen - State Type: ${state.runtimeType}");
          debugPrint(
            "🔍 Wardrobe Screen - Is WardrobeItemsLoaded: ${state is WardrobeItemsLoaded}",
          );
          debugPrint(
            "🔍 Wardrobe Screen - Is WardrobeLoading: ${state is WardrobeLoading}",
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              centerTitle: true,
              title: const Text(
                "Your Wardrobe",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            body: FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? size.width * 0.1 : 16,
                  vertical: 16,
                ),
                child: _buildWardrobeContent(state, isTablet),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const AddItemScreen(),
                  ),
                );

                // Refresh wardrobe items after adding new item
                if (result != null) {
                  context.read<WardrobeBloc>().add(FetchWardrobeItemsEvent());
                }
              },
              backgroundColor: const Color(0xFF7E57C2), // Soft violet
              elevation: 6,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Item",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWardrobeContent(WardrobeState state, bool isTablet) {
    debugPrint("🔍 _buildWardrobeContent - State: $state");
    debugPrint("🔍 _buildWardrobeContent - State Type: ${state.runtimeType}");

    if (state is WardrobeLoading) {
      debugPrint("🔍 _buildWardrobeContent - Showing Loading");
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5A4FCF)),
      );
    } else if (state is WardrobeItemsLoaded) {
      debugPrint(
        "🔍 _buildWardrobeContent - Items Count: ${state.items.length}",
      );
      debugPrint("🔍 _buildWardrobeContent - Items: ${state.items}");
      if (state.items.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.checkroom_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Your wardrobe is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add some clothes to get started!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<WardrobeBloc>().add(FetchWardrobeItemsEvent());
        },
        color: const Color(0xFF5A4FCF),
        child: GridView.builder(
          itemCount: state.items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: isTablet ? 24 : 20,
            mainAxisSpacing: isTablet ? 24 : 20,
            childAspectRatio: isTablet ? 0.8 : 0.75,
          ),
          itemBuilder: (context, index) {
            final item = state.items[index];
            return _buildClothingCard(item);
          },
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your wardrobe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildClothingCard(WardrobeItem item) {
    debugPrint("🔍 _buildClothingCard - Item: $item");
    debugPrint("🔍 _buildClothingCard - Image URL: ${item.imageUrl}");

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        debugPrint("🔍 Tapped on item ID: ${item.id}");
        debugPrint("🔍 Item name: ${item.name}");
        debugPrint("🔍 Item category: ${item.category}");
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<WardrobeBloc>(),
              child: WardrobeDetailScreen(item: item.toJson()),
            ),
          ),
        );

        // Refresh wardrobe items if an item was deleted
        if (result == true) {
          debugPrint("🔍 Wardrobe Screen - Item was deleted, refreshing items");
          context.read<WardrobeBloc>().add(FetchWardrobeItemsEvent());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section with flexible height
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF5A4FCF),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content section with minimal padding
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
