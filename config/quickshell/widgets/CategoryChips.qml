import QtQuick 2.15
import QtQuick.Controls 2.15
import eclipsecalis.theme 1.0

Row {
    id: categoryChips
    spacing: 4
    readonly property string[] categories: ["General", "Anime", "People"]
    readonly property int[] categoryBits: ["110", "010", "001"]

    // Selected category state
    property int selectedIndex: 0

    // Toggle button
    function toggleCategory(index) {
        selectedIndex = index;
        // Emit signal with the category bit string
        if (onCategoryChanged) {
            onCategoryChanged(categoryBits[index]);
        }
    }

    // Render category chips
    Repeater {
        model: 3
        delegate: FilterChoice {
            id: choice
            text: categories[index]
            isSelected: (index === categoryChips.selectedIndex)
            onToggled: {
                categoryChips.toggleCategory(index);
            }
        }
    }
}