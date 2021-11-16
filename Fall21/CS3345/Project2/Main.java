public class Main {
    public static void main(String[] args) {
        int[] arr = {10, 7, 1, 5, 2, 3, 4, 6, 9, 8};

        for(int i = 0; i < arr.length; i++) {
            System.out.print(arr[i] + " ");
        }
        System.out.println();

        mergeSort(arr, 0, arr.length - 1);

        for(int i = 0; i < arr.length; i++) {
            System.out.print(arr[i] + " ");
        }
        System.out.println();

    }
    public static void mergeSort(int[] arr, int l, int r) {
        if(l < r) {
            int m = l + (r - l) / 2;

            mergeSort(arr, l, m); // split and sort left
            mergeSort(arr, m + 1, r); // split and sort right

            merge(arr, l, m, r);
        }
    }
    public static void merge(int[] arr, int l, int m, int r) {
        int sizeArr1 = m + 1 - l;
        int sizeArr2 = r - m;

        // make temp arrays
        int[] subArr1 = new int[sizeArr1];
        int[] subArr2 = new int[sizeArr2];

        // copy into temp arrays
        for(int i = 0; i < sizeArr1; i++) {
            subArr1[i] = arr[i + l];
        }
        for(int i = 0; i < sizeArr2; i++) {
            subArr2[i] = arr[i + m + 1];
        }

        int i = 0, j = 0, k = l;
        while(i < sizeArr1 && j < sizeArr2) {
            if(subArr1[i] <= subArr2[j]) {
                arr[k] = subArr1[i];
                i++;
            }
            else {
                arr[k] = subArr2[j];
                j++;
            }
            k++;
        }
        while(i < sizeArr1) {
            arr[k] = subArr1[i];
            i++;
            k++;
        }
        while(j < sizeArr2) {
            arr[k] = subArr2[j];
            j++;
            k++;
        }
    }
}
