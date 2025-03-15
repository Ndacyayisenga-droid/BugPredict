# BugPredict

# Defect Prediction in Software Repositories: A Comprehensive Analysis

## 1. Introduction
In this analysis after cleaning up the [BugTool](https://github.com/adoptium/aqa-test-tools/tree/master/BugPredict/BugTool), I explored defect prediction using a historical commit-based approach (Approach A) on two types of repositories: a large, highly active repository ([OpenJ9](https://github.com/eclipse-openj9/openj9)) and a small, less active repository ([Hiero](https://github.com/OpenElements/hiero-enterprise-java)). By leveraging historical commit data, I assessed the effectiveness of this method in identifying defect-prone files and evaluated its scalability, accuracy, and limitations.

## 2. Objectives
The primary objectives of this study were:
- To evaluate the effectiveness of historical commit-based defect prediction.
- To compare the behavior of defect scores between large and small repositories.
- To visualize the correlation between commit frequency and defect likelihood.
- To identify strengths, weaknesses, and practical implications of this approach.

## 3. Methodology
To conduct this analysis, I followed these steps:

### 3.1 Data Collection
I obtained repository data from two sources:
- **Large Repository [(OpenJ9)](https://github.com/eclipse-openj9/openj9)** – A highly active repository with thousands of commits. The openj9 metrics data can be found [here](https://github.com/Ndacyayisenga-droid/BugPredict/blob/master/openj9Metrics.json)
  - Am able to collect the above metrics and store them in an online mongodb cluster as shown in the screenshot below
  - <img width="1673" alt="Screenshot 2025-03-15 at 20 23 21" src="https://github.com/user-attachments/assets/207f9ac9-383b-4847-b89a-0e6b5990f190" />

- **Small Repository [(Hiero)](https://github.com/OpenElements/hiero-enterprise-java)** – A repository with significantly fewer commits and contributors. The hiero metrics data can be found [here](https://github.com/Ndacyayisenga-droid/BugPredict/blob/master/hieroMetrics.json)
  - Am able to collect the above metrics and store them in an online mongodb cluster as shown in the screenshot below
  -  <img width="1673" alt="Screenshot 2025-03-15 at 20 25 18" src="https://github.com/user-attachments/assets/5b450396-da69-4fba-83a8-e5c7ae966da0" />

Each repository's data included:
- **File Name**: The source code file being analyzed.
- **Defect Score**: A numerical measure indicating the likelihood of defects based on past commit history.
- **Commit History**: A list of commit messages and timestamps for each file.

### 3.2 Tools Used
To process and analyze the data, I used:
- **Python (Pandas, Matplotlib, Seaborn)**: For data manipulation and visualization.
- **Jupyter Notebook**: To facilitate interactive analysis.
- **JSON Processing**: To parse and extract relevant repository data.

### 3.3 Data Processing
I structured the data as follows:
- Extracted defect scores and commit counts from the JSON files.
- Created a structured DataFrame using Pandas.
- Filtered out irrelevant or low-activity files.
- Plotted scatter graphs to visualize commit frequency vs. defect score.

## 4. Data Processing and Preprocessing

### 4.1 Large Repository [(OpenJ9)](https://github.com/eclipse-openj9/openj9)
The large repository dataset contained thousands of commits per file. The defect scores ranged from 10.4 (highest risk) to near zero (lowest risk). The highest-ranked file was `runtime/oti/j9nonbuilder.h`, which had a defect score of 10.3999 with numerous commit changes, indicating strong correlation between high commit frequency and defect likelihood.

### 4.2 Small Repository [(Hiero)](https://github.com/OpenElements/hiero-enterprise-java)
The small repository dataset showed significantly lower defect scores, with the highest being 0.3253 for `TestConfigSource.java`. Unlike the large repository, even files with multiple commits had relatively low defect scores, suggesting that the historical commit-based approach may be less effective in smaller repositories due to limited commit data.

## 5. Analysis & Findings

### 5.1 Correlation Between Commit Frequency and Defect Score
- **Large Repository**: High commit frequency correlated with higher defect scores, validating the assumption that frequently modified files are more defect-prone.
- **Small Repository**: No clear correlation; defect scores remained low across files regardless of commit frequency.

### 5.2 Scatter Plot Visualization
I generated scatter plots to visualize the relationship between commit count and defect score:
- **Blue dots (Large Repository)**: Showed a clear upward trend, indicating a positive correlation.
- **Red dots (Small Repository)**: Were scattered with no clear trend, reinforcing the idea that this method is less effective for small repositories.
![commit_vs_defect_score_no_title](https://github.com/user-attachments/assets/72eb9d89-99a6-4ef9-a60c-8fe7a4d8a49c)

## 6. Strengths and Weaknesses of Approach A

### 6.1 Strengths
- **Scalability**: Works well for large repositories with extensive commit history.
- **Low Computational Cost**: Does not require deep code analysis, only commit history.
- **Quick Insights**: Identifies high-risk files efficiently.

### 6.2 Weaknesses
- **Limited Effectiveness in Small Repositories**: Insufficient commit history results in unreliable defect scores.
- **Cannot Detect New Bugs**: Only identifies defects based on past fixes.
- **Repository-Dependent Behavior**: Relies on repositories having a history of frequent bug fixes.

## 7. Challenges Encountered

### 7.1 Data Cleaning Issues
- Extracting structured information from JSON required careful preprocessing.
- Some files had inconsistent commit history, requiring additional filtering.

### 7.2 Interpretation Challenges
- Small repositories posed difficulties in deriving meaningful trends.
- Need for additional methods (e.g., static analysis) to complement historical defect prediction.

## 8. Technical Implications
The findings suggest that historical commit-based defect prediction is highly effective for large repositories but struggles with smaller ones. Organizations relying on this approach should:
- Complement it with static code analysis for small repositories.
- Focus on highly active files in large repositories for defect mitigation.
- Use a hybrid model that integrates multiple defect prediction techniques.

## 9. Conclusion & Recommendations

### 9.1 Key Takeaways
- Large repositories benefit greatly from this method.
- Small repositories need alternative approaches for better defect prediction.
- Commit frequency is a strong indicator of defect-prone files in active repositories.

### 9.2 Next Steps
To enhance the accuracy of defect prediction, I recommend:
- Combining historical commit-based analysis with machine learning models.
- Applying static analysis techniques for small repositories.
- Exploring deep learning methods for better defect classification.
