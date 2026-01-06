namespace Sort {
    funcdef int PlaylistSort(MapPlaylist@ a, MapPlaylist@ b);

    const array<PlaylistSort@> playlistMethods = {
        SortName,
        SortMapCount,
        SortTags,
        SortCreatedAt
    };

    int SortName(MapPlaylist@ a, MapPlaylist@ b) {
        return SortString(a.Name, b.Name);
    }

    int SortMapCount(MapPlaylist@ a, MapPlaylist@ b) {
        return Math::Clamp(a.Length - b.Length, -1, 1);
    }

    int SortTags(MapPlaylist@ a, MapPlaylist@ b) {
        if (a.Tags.IsEmpty() && b.Tags.IsEmpty()) {
            return SortString(a.Name, b.Name);
        }

        if (a.Tags.IsEmpty()) {
            return -1;
        }

        if (b.Tags.IsEmpty()) {
            return 1;
        }

        uint maxLength = Math::Max(a.Tags.Length, b.Tags.Length);

        for (uint i = 0; i < maxLength; i++) {
            if (a.Tags.Length <= i) {
                return -1;
            }

            if (b.Tags.Length <= i) {
                return 1;
            }

            int nameResult = SortString(a.Tags[i].Name, b.Tags[i].Name);
            if (nameResult != 0) return nameResult;
        }

        return 0;
    }

    int SortCreatedAt(MapPlaylist@ a, MapPlaylist@ b) {
        return Math::Clamp(a.CreatedAt - b.CreatedAt, -1, 1);
    }

    // Original code from Better TOTD by Xertrov
    void PlaylistQuickSort(PlaylistsManager@ lists, PlaylistSort@ f, bool descending, int left = 0, int right = -1) {
        if (right < 0) right = lists.Length - 1;
        if (lists.Length == 0) return;

        int i = left;
        int j = right;
        MapPlaylist@ pivot = lists[(left + right) / 2];

        while (i <= j) {
            if (descending) {
                while (f(lists[i], pivot) > 0) i++;
                while (f(lists[j], pivot) < 0) j--;
            } else {
                while (f(lists[j], pivot) > 0) j--;
                while (f(lists[i], pivot) < 0) i++;
            }

            if (i <= j) {
                MapPlaylist@ temp = lists[i];
                @lists[i] = lists[j];
                @lists[j] = temp;
                i++;
                j--;
            }
        }

        if (left < j) PlaylistQuickSort(lists, f, descending, left, j);
        if (i < right) PlaylistQuickSort(lists, f, descending, i, right);
    }

    void SortPlaylists(UI::TableSortSpecs@ tableSpecs) {
        if (savedPlaylists.Length < 2) {
            return;
        }

        foreach (UI::TableColumnSortSpecs spec : tableSpecs.Specs) {
            if (spec.SortDirection == UI::SortDirection::None) {
                continue;
            }

            switch (spec.ColumnIndex) {
                case 0:
                case 5:
                    // Can't sort indexes or buttons
                    continue;
                default:
                    if (spec.ColumnIndex - 1 >= int(playlistMethods.Length)) {
                        continue;
                    }

                    PlaylistQuickSort(savedPlaylists, playlistMethods[spec.ColumnIndex - 1], spec.SortDirection == UI::SortDirection::Descending);
                    break;
            }
        }

        tableSpecs.Dirty = false;
        savedPlaylists.Dirty = false;
    }
}
