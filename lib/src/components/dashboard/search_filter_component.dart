import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:intl/intl.dart';

/// Search and filter component for subscriptions.
class SearchFilterComponent extends StatefulWidget {
  const SearchFilterComponent({super.key});

  @override
  State<SearchFilterComponent> createState() => _SearchFilterComponentState();
}

class _SearchFilterComponentState extends State<SearchFilterComponent> {
  bool _isExpanded = false;
  String _selectedCategory = 'All';
  String _selectedType = 'All'; // All, Monthly, Yearly
  String _selectedStatus = 'All'; // All, Active, Expired

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aboController = Provider.of<AboController>(context);
    final abos = aboController.abos;

    // Get unique categories
    final categories = ['All', ...abos.map((a) => a.category).where((c) => c != null).cast<String>().toSet()];
    final types = ['All', 'Monthly', 'Yearly'];
    final statuses = ['All', 'Active', 'Expired'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.cardColor,
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => aboController.filterAbosByName(value),
                      decoration: InputDecoration(
                        hintText: 'Search subscriptions...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.primaryColor.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      setState(() => _isExpanded = !_isExpanded);
                    },
                    icon: Icon(
                      _isExpanded ? Icons.filter_alt_off : Icons.filter_alt,
                      color: theme.primaryColor,
                    ),
                    tooltip: _isExpanded ? 'Hide filters' : 'Show filters',
                  ),
                ],
              ),
            ),

            // Filter Options (expandable)
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Filter
                    _buildFilterRow(
                      theme,
                      'Category',
                      _selectedCategory,
                      categories,
                      (value) {
                        setState(() => _selectedCategory = value!);
                        // TODO: Implement category filter in controller
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Type Filter
                    _buildFilterRow(
                      theme,
                      'Type',
                      _selectedType,
                      types,
                      (value) {
                        setState(() => _selectedType = value!);
                        // TODO: Implement type filter in controller
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Status Filter
                    _buildFilterRow(
                      theme,
                      'Status',
                      _selectedStatus,
                      statuses,
                      (value) {
                        setState(() => _selectedStatus = value!);
                        // TODO: Implement status filter in controller
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Clear All Filters
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _selectedType = 'All';
                            _selectedStatus = 'All';
                          });
                          aboController.clearAllFilters();
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Filters'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: theme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Active Filters Summary
            if (!_isExpanded && _hasActiveFilters())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedCategory != 'All')
                      _buildFilterChip(theme, 'Category: $_selectedCategory', () {
                        setState(() => _selectedCategory = 'All');
                      }),
                    if (_selectedType != 'All')
                      _buildFilterChip(theme, 'Type: $_selectedType', () {
                        setState(() => _selectedType = 'All');
                      }),
                    if (_selectedStatus != 'All')
                      _buildFilterChip(theme, 'Status: $_selectedStatus', () {
                        setState(() => _selectedStatus = 'All');
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != 'All' || _selectedType != 'All' || _selectedStatus != 'All';
  }

  Widget _buildFilterRow(
    ThemeData theme,
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                onChanged: onChanged,
                items: options.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, VoidCallback onRemoved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemoved,
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
